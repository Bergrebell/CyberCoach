class User < ActiveRecord::Base
  has_many :credits

  # Will be available by the CyberCoach base wrapper class from Alex
  BASE_PATH = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users'


  # Authenticate user credentials against data on CyberCoach webservice
  #
  def self.authenticate(username, password)
    response = RestClient.get(BASE_PATH, {:params => {:username => username, :password => password}})
    print "Response: " + response.code.to_s
    return response.code == 401 ? false : true
  end

  # Checks if this user is logged in
  #
  def is_logged_in
    session[:username] == self.username
  end

end
