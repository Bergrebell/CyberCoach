class Track < ActiveRecord::Base
  belongs_to :user
  belongs_to :sport_session_participant
end
