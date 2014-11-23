class UserAchievement < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
  belongs_to :sport_session
end
