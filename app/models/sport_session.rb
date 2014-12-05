class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants
  belongs_to :user

  validates :title, presence: true
  validates :location, presence: true
  validates :entry_time, presence: true
  validates :entry_date, presence: true

  # Virtual attribute, this one is merged into the date
  #
  def entry_time=(param)
    @entry_time = param
  end

  def entry_time
    if date.present?
      date.strftime('%H:%M')
    end
  end

  def entry_date=(param)
    @entry_date = param
  end

  def entry_date
    if date.present?
      date.strftime '%Y-%m-%d'
    end
  end

  def is_past
    self.date < Date.today
  end

  def is_upcoming
    self.date > Date.today
  end

  # Return the number of confirmed participants
  def n_participants
    self.sport_session_participants.where(:confirmed => true).count
  end

  def is_confirmed_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id, :confirmed => true).exists?
  end

  def is_unconfirmed_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id, :confirmed => false).exists?
  end

  def is_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id).exists?
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


  # Return results of all users participated at this session
  #
  def get_all_results
    raise 'Must be implemented by subclass!'
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


  # find the given user's sport sessions based on filters (based on Stefan's CarTrading filter for offers)
  def self.all_sport_sessions_filtered_from_user(user_id, params, confirmed, type)
    if confirmed
      filtered_sessions = self.all_sport_sessions_confirmed_from_user(user_id, type)
    else
      filtered_sessions = self.all_sport_sessions_unconfirmed_from_user(user_id, type)
    end

    if params[:entry_location].present?
      filtered_sessions = filtered_sessions.where('location LIKE ?', "%#{params[:entry_location]}%")

    end

    if params[:date_to].present? && params[:date_from].present?
      date_from = DateTime.strptime(params[:date_from], Facade::SportSession::DATETIME_FORMAT)
      date_to = DateTime.strptime(params[:date_to], Facade::SportSession::DATETIME_FORMAT)+1
      date_range = {date: date_from..date_to}
      filtered_sessions = filtered_sessions.where(date_range)
    end

    if params[:participant].present?
      participant = {user_id: params[:participant]}
      filtered_sessions = filtered_sessions.joins(:sport_session_participants).where(sport_session_participants: participant)
    end

    filtered_sessions

  end

end
