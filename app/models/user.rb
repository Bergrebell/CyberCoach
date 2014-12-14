class User < ActiveRecord::Base
  has_many :credits
  has_many :sport_sessions
  has_many :sport_sessions, through: :sport_session_participants
  has_many :sport_session_participants

  has_many :tracks

  has_many :achievements, through: :user_achievements
  has_many :user_achievements

  # password rules for creating a new user
  validates :password, length: {within: 4..10}, on: :create
  validates_presence_of :password_confirmation, on: :create
  validates_confirmation_of :password,  on: :create


  # password rules for updating a user
  validates :new_password, length: {within: 4..10}, :if => :new_password_present?, on: :update
  validates_presence_of :password_confirmation, :if => :new_password_present?, on: :update
  validates_confirmation_of :new_password, :if => :new_password_present?, on: :update


  validates :real_name, presence: true
  validates :username, presence: true, length: {within: 4..50}, uniqueness: true
  validates :email, email_format: {message: "Doesn't look like an email address!"}


  after_create :create_coach_user
  after_find :load_coach_user
  after_update :update_coach_user


  def get_coach_user
    coach_user = Coach.user(self.username)
  end


  def create_coach_user
    begin
      coach_user = Coach.create_user do |user|
        user.real_name = self.real_name
        user.username = self.username
        user.email = self.email
        user.password = self.password
      end

      if coach_user
        subscribe_user_to_sports(coach_user)
      else
        self.delete
      end
    rescue
      # do nothing
    end
  end


  def subscribe_user_to_sports(coach_user)
    proxy = Coach4rb::Proxy::Access.new self.username, self.password, Coach
    res = [:running, :cycling, :boxing, :soccer].map do |sport|
      Thread.new { proxy.subscribe(coach_user, sport) }
    end
  end


  def update_coach_user
    proxy = Coach4rb::Proxy::Access.new self.username, self.password, Coach
    raise 'Update Error' unless proxy.valid?

    coach_user = proxy.update_user(get_coach_user) do |user|
      user.email = self.email if self.email.present?
      user.real_name = self.real_name if self.real_name.present?

      if self.new_password.present?
        user.password = self.new_password
        self.update_column(:password, self.new_password)
      end

    end
    ObjectStore::Store.set([:coach_user,self.id],coach_user)
  end


  def load_coach_user
    coach_user = ObjectStore::Store.get([:coach_user,self.id])
    if coach_user.nil?
      coach_user = Coach.user self.username
      ObjectStore::Store.set([:coach_user,self.id],coach_user)
      self.email = coach_user.email
      self.real_name = coach_user.real_name
      self.public_visible = coach_user.public_visible
    end
    self.email = coach_user.email unless self.email
    self.real_name = coach_user.real_name unless self.real_name
    self.public_visible = coach_user.public_visible unless self.public_visible
  end



  def password_present?
    !password.nil?
  end


  def new_password_present?
    new_password.present?
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
    # friend_ids = Friendship.select(:friend_id).where user_id: self.id
    # friend_ids ||= []
    # User.where.not( id: friend_ids).where.not( id: self.id) # get all user that are not are not in the list of friend ids

    sent_ids = self.sent_friend_requests.map { |friend| friend.id} || []
    received_ids = self.received_friend_requests.map { |friend| friend.id} || []
    friend_ids = self.friends.map { |friend| friend.id } || []

    ids = friend_ids + received_ids +  sent_ids
    ids +=[-1] if ids.size == 0 # edge case: if ids is empty this corresponds to null!
    # dirty hack: assume that no user will ever have an negative id.

    User.where('id NOT IN (?) AND id != ?', ids, self.id)

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

  def new_password
    @new_password
  end

  def new_password=(param)
    @new_password = param
  end

  def password_confirmation
    @password_confirmation
  end

  def password_confirmation=(param)
    @password_confirmation = param
  end

  alias_method :new_password_confirmation, :password_confirmation
  alias_method :new_password_confirmation=, :password_confirmation=


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


  def points
    UserAchievement.joins(:achievement).where(user_id: self.id).select(:points).sum(:points)
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
    #SportSessionParticipant.where("confirmed = ? AND sport_session_id IN (#{session_ids.join(', ')})", true).select(:user_id).distinct
    #SportSessionParticipant.where(confirmed: true, sport_session_id: session_ids).select(:user_id).distinct
    SportSessionParticipant.where("confirmed = ? AND sport_session_id IN (?)", true, session_ids).select(:user_id).distinct
  end

  def sport_sessions_filtered(params, confirmed, type='')
    if params.count == 0
      sport_sessions_confirmed(type)
    else
      SportSession.all_sport_sessions_filtered_from_user(self.id, params, confirmed, type)
    end
  end



end
