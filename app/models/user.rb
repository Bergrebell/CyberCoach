class User < ActiveRecord::Base
  has_many :credits
  has_many :sport_sessions
  has_many :sport_sessions, through: :sport_session_participants
  has_many :sport_session_participants

  has_many :tracks
  has_many :user_achievements
  has_many :achievements, through: :user_achievements

  validates :password, length: {within: 4..10}
  validates_presence_of :password_confirmation, :if => :password_present?, on: :create
  validates_confirmation_of :password, :if => :password_present?, on: :create

  validates :real_name, presence: true
  validates :username, presence: true, length: {within: 4..50}, uniqueness: true
  validates :email, email_format: {message: "Doesn't look like an email address!"}


  after_create :create_coach_user
  after_find :load_coach_user
  after_update :update_coach_user


  def coach_user
    @coach_user
  end


  def create_coach_user
    coach_user = Coach.create_user do |user|
      user.real_name = self.real_name
      user.username = self.username
      user.email = self.email
      user.password = self.password
    end
    self.delete unless coach_user
  end


  def update_coach_user
    proxy = Coach4rb::Proxy::Access.new self.username, self.password,Coach
    proxy.update_user(coach_user) do |user|
      user.email = self.email
      user.real_name = self.real_name
    end
  end


  def load_coach_user
    @coach_user = Coach.user self.username
    if @coach_user
      self.real_name = @coach_user.real_name
      self.email = @coach_user.email
      self.public_visible = @coach_user.public_visible
    end
  end



  def password_present?
    !password.nil?
  end


  # Returns a list of past sport sessions.
  # @return [List]
  #
  def past_sport_sessions
    sport_sessions_confirmed.where('date < ?', Date.today).limit(3)  #TODO: maybe we should use DateTime.now or Date.now
  end


  # Returns a list of upcoming sport sessions.
  # @return [List]
  #
  def upcoming_sport_sessions
    sport_sessions_confirmed.where('date >= ?', Date.today).limit(3)  #TODO: maybe we should use DateTime.now or Date.now
  end


  # Returns a list of the latest obtained achievements.
  # @return [List]
  #
  def latest_achievements
    achievements.order('user_achievements.created_at DESC').limit(5)
  end


  # Return friends of this user
  #
  def friends
    friendships = Friendship.where('(user_id = ? OR friend_id = ?) AND confirmed = ?', self.id, self.id, true)
    users = []
    friendships.each do |friendship|
      if friendship.user_id == self.id
        users.push User.find friendship.friend_id
      else
        users.push User.find friendship.user_id
      end
    end

    users
  end


  # Return received friend requests not yet confirmed
  #
  def received_friend_requests
    friendships = Friendship.where(:friend_id => self.id, :confirmed => false)
    users = []
    friendships.each do |friendship|
      users.push User.find_by_id friendship.user_id
    end

    users
  end


  # Return sent friend request not yet confirmed
  #
  def sent_friend_requests
    friendships = Friendship.where(:user_id => self.id, :confirmed => false)
    users = []
    friendships.each do |friendship|
      users.push User.find friendship.friend_id
    end

    users
  end

  # Return array of users not yet befriended with the current user
  #
  def friends_proposals
    # get all friend ids
    friend_ids = Friendship.select(:friend_id).where user_id: self.id
    friend_ids ||= []
    User.where.not( id: friend_ids).where.not( id: self.id) # get all user that are not are not in the list of friend ids
  end

  # Returns true if the current user if befriended with the other user
  #
  def befriended_with(other_user)
    sql_stmt = '(user_id = :first_id OR friend_id = :first_id)
                  AND (user_id = :second_id OR friend_id = :second_id)
                    AND (:first_id != :second_id)
                      AND confirmed = :confirmed'
    Friendship.where(sql_stmt, first_id: self.id, second_id: other_user.id, confirmed: true).exists?
  end

  # create some virtual attributes
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

  def is_participant_of(sport_session_id)
    if sport_session_id.nil?
      false
    else
      SportSessionParticipant.where(:user_id => self.id, :sport_session_id => sport_session_id).exists?
    end
  end

  def sport_sessions_confirmed(type='')
    SportSession.all_sport_sessions_confirmed_from_user(self.id, type)
  end

  def sport_sessions_unconfirmed(type='')
    SportSession.all_sport_sessions_unconfirmed_from_user(self.id, type)
  end

  def confirmed_participants_of_all_sessions
    session_ids = self.sport_sessions_confirmed.map{|s|s.id}
    SportSessionParticipant.where("confirmed = ? AND sport_session_id IN (#{session_ids.join(', ')})", true).select(:user_id).distinct
  end

  def sport_sessions_filtered(params, confirmed, type='')
    SportSession.all_sport_sessions_filtered_from_user(self.id, params, confirmed, type)
  end



end
