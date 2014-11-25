class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants


  # Virtual attribute, this one is merged into the date
  #
  def entry_time=(param)
    @entry_time = param
  end

  def entry_time
    if self.date.present?
      self.date.strftime('%H:%M')
    end
  end

  def is_past
    self.date < Date.today
  end

  def is_upcoming
    self.date > Date.today
  end

  # Invite some users to join this event
  # @param user_ids Array of User-IDs
  #
  def invite(user_ids)

    if not user_ids.kind_of?(Array)
      return
    end

    # Remove any records not confirmed first
    sessions_participants = SportSessionParticipant.where(:sport_session_id => self.id, :confirmed => false)
    sessions_participants.each do |session_participant|
      session_participant.destroy
    end

    # Create SportSessionParticipant objects if not existing
    user_ids.each do |user_id|
      SportSessionParticipant.where(:sport_session_id => self.id, :user_id => user_id).first_or_create(:confirmed => false)
    end

  end


  # Factory method to return the result object for given user
  # @param user Rails user model
  #
  def result(user)
    participant = SportSessionParticipant.where(:user_id => user.id, :sport_session_id => self.id, :confirmed => true).first!

    case self.type
      when 'Running'
        result = RunningParticipantResult.where(:sport_session_participant_id => participant.id).first_or_create
      when 'Boxing'
        result = BoxingParticipantResult.where(:sport_session_participant_id => participant.id).first_or_create
      else
        raise 'Unknown Type'
    end

    result
  end


  # Return any achievement obtained by this event from the given user
  # @param user Rails user model
  #
  def achievements_obtained(user)
    user_achievements = UserAchievement.where(:sport_session_id => self.id, :user_id => user.id)
    achievements = user_achievements.map { |user_achievement| user_achievement.achievement }
  end


  # Return all SportSessions where the given user participated
  #
  def self.all_sessions_from_user(user_id, type='', confirmed=nil)
    where = {:user_id => user_id}
    if not confirmed.nil?
      where[:confirmed] = confirmed
    end
    if type.present?
      SportSession.where(:type => type).joins(:sport_session_participants).where(sport_session_participants: where)
    else
      SportSession.joins(:sport_session_participants).where(sport_session_participants: where)
    end

  end


  def self.all_sport_sessions_confirmed_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, true)
  end

  def self.all_sport_sessions_unconfirmed_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, false)
  end

end
