class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  helper_method :current_user,

  private

  def require_login
    if session[:user].present?
      # We are logged in, define a global user variable for the app -> here again use Alex's wrapper class
      # Or get relevant user data also from session so that we don't need to fetch user data from Cybercoach on every request
    else
      redirect_to '/welcome/index', alert: 'Please login to access this section'
    end
  end


  # Returns an AuthProxy object if the current user is authenticated.
  # Otherwise it returns nil.
  def current_user
    if session[:user].present?
      # wrap user hash into a look-a-like user object
      user = RestAdapter::User.new(session[:user])
      auth_proxy = RestAdapter::AuthProxy.new(user: user, subject: user)
    else
      nil
    end
  end


end
