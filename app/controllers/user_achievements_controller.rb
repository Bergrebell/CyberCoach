class UserAchievementsController < ApplicationController

  def index
    @achievements = Achievement.all
    @user_achievements = current_user.achievements.all
  end

end