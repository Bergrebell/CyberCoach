class WelcomeController < ApplicationController
  skip_before_action :require_login

  def index
    if
    @user = current_user
    @achievements = @user.latest_achievements
    @sports = @user.sport_sessions
    #@requests_received = current_user.received_friend_requests
    @friends = current_user.friends
    end
  end
end
