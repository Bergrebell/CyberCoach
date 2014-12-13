class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  helper_method :current_user
  helper_method :auth_proxy


  private

  def require_login
    if session[:username].present?
      # We are logged in, define a global user variable for the app -> here again use Alex's wrapper class
      # Or get relevant user data also from session so that we don't need to fetch user data from Cybercoach on every request
    else
      redirect_to '/welcome/index', alert: 'Please login to access this section'
    end
  end


  # This method returns the current logged in user.
  # Returns a Facade::User user object if user is logged in otherwise nil.
  #
  # ==== Example
  # self.current_user => Facade::User
  #
  def current_user
    if session[:username].present?
      user = ObjectStore::Store.get(session[:username])
      user = Facade::User.authenticate(session[:username],session[:password]) unless user
      ObjectStore::Store.set(session[:username],user)
      user
    else
      nil
    end
  end



end
