class User < ActiveRecord::Base
  has_many :credits

  validates :password, confirmation: true
  validates :real_name, presence: true
  validate :username_available
  validates :email, email_format: { message: "Doesn't look like an email address!" }

  # create some virtual attributes
  def username=(param)
    @username = param
  end

  def username
    @username
  end

  def password=(param)
    @password = param
  end

  def password
    @password
  end

  def password_confirmation
    @password_confirmation
  end

  def password_confirmation=(param)
    @password_confirmation = param
  end

  def email=(param)
    @email = param
  end

  def email
    @email
  end

  def real_name
    @real_name
  end

  def real_name=(param)
    @real_name = param
  end

  def public_visible=(param)
    @public_visible = param
  end

  def public_visible
    @public_visible
  end

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

  # Validate against cyber coach if username is available.
  def username_available
    if not RestAdapter::User.username_available?(@username)
      errors.add(:username,"Username is not available or invalid.")
    end
  end

end
