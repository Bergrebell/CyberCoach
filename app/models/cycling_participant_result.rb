class CyclingParticipantResult < ActiveRecord::Base
  belongs_to :sport_session_participant
  has_one :sport_session, through: :sport_session_participant
  has_one :user, through: :sport_session_participant

  validates :length, presence: true, on: :update
  validates :time, presence: true, on: :update

end