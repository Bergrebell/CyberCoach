class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants

  # Invite some users to join this event
  #
  #
  def invite(user_ids)
    user_ids.each do |user_id|
      p = SportSessionParticipant.new(:user_id => user_id, :sport_session_id => self.id)
      p.save()
    end
  end

end
