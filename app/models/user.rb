class User < ActiveRecord::Base
  has_many :credits

  def initialize(params={})
    # use this class as a proxy for the adapter object
    @cc_user = params[:user].present? ? params[:user] : nil
  end

  # Authenticate user credentials against data on CyberCoach webservice.
  # If user authentication succeeds a a lookalike user object is returned, otherwise it returns false.
  #
  def self.authenticate(username, password)
    user = CyberCoachUser.authenticate(username: username, password: password)
  end

  # Checks if this user is logged in
  #
  def self.is_logged_in
    session[:user].present?
  end

  def email
    @cc_user.email
  end

  def username
    @cc_user.username
  end

  def is_public?
    @cc_user.publicvisible == RestResource::Privacy::Public
  end

  def is_private?
    @cc_user.publicvisible == RestResource::Privacy::Private
  end

  def members_only?
    @cc_user.publicvisible == RestResource::Privacy::Member
  end



end
