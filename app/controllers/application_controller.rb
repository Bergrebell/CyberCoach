class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login


  private

  def require_login
    if session[:username].present?
      # We are logged in, define a global user variable for the app -> here again use Alex's wrapper class
      # Or get relevant user data also from session so that we don't need to fetch user data from Cybercoach on every request
      @current_user = User.new
    else
      redirect_to '/welcome/index', alert: 'Please login to access this section'
    end
  end
end
