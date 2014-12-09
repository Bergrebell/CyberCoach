class WelcomeController < ApplicationController
  skip_before_action :require_login

  def index
    if
    @user = current_user
    @friends = @user.friends
    @achievements = @user.latest_achievements
    @upcoming_sport_sessions = @user.upcoming_sport_sessions
    @past_sport_sessions = @user.past_sport_sessions
    end
  end
end
