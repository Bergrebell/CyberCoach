class WelcomeController < ApplicationController
  skip_before_action :require_login

  def index
    if current_user
      @user = current_user
      @items = Timeline.items(current_user)
      @friends = @user.friends
    end
  end
end
