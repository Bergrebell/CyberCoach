class WelcomeController < ApplicationController
  skip_before_action :require_login

  def index
    @items = Timeline.items(current_user)
  end
end
