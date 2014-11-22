class UserAchievements < ActiveRecord::Base
  belongs_to :User
  belongs_to :Achievement
  belongs_to :SportSession
end
