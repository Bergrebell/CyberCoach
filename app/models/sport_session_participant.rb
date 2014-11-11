class SportSessionParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :sport_session
  has_one :boxing_participant_result
  has_one :running_participant_result
end
