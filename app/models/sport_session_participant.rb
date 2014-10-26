class SportSessionParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :sport_session
end
