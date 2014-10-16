class User < ActiveRecord::Base
  has_many :credits

  # Authenticate user credentials against data on CyberCoach webservice.
  # If user authentication succeeds a a lookalike user object is returned, otherwise it returns false.
  #
  def self.authenticate(username, password)
    user = RestAdapter::User.authenticate(username: username, password: password)
  end

  # Checks if this user is logged in
  #
  def self.is_logged_in
    session[:user].present?
  end


end
