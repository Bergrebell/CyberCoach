class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants


  # Invite some users to join this event
  # @param array user_ids
  #
  def invite(user_ids)

    # Remove any records not confirmed first
    sessions_participants = SportSessionParticipant.where(:sport_session_id => self.id, :confirmed => false)
    sessions_participants.each do |session_participant|
      session_participant.destroy
    end

    # Create SportSessionParticipant objects if not existing
    user_ids.each do |user_id|
      if SportSession.where(:sport_session_id => self.id, :user_id => user_id).first.nil?
        p = SportSessionParticipant.new(:user_id => user_id, :sport_session_id => self.id)
        p.save
      end
    end
  end

end
