class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants


  # Invite some users to join this event
  # @param array user_ids
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


  def self.confirmed_sessions_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, true)
  end

  def self.unconfirmed_sessions_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, false)
  end

end
