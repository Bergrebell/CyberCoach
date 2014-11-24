class UserAchievementsController < ApplicationController

  def index

    @achievements = Achievement.all
    @user_achievements = UserAchievement.where('user_id' => current_user.id)

  end

end