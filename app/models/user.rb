class User < ActiveRecord::Base
  has_many :credits
  has_many :sport_sessions
  has_many :sport_sessions, through: :sport_session_participants
  has_many :sport_session_participants

  validates :password, presence: true, confirmation: true, length: {within: 4..10}
  validates :real_name, presence: true
  validates :username, presence: true, length: {within: 4..50}
  validates :email, email_format: {message: "Doesn't look like an email address!"}


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
    Friendship.where('(user_id = ? OR friend_id = ?) AND (user_id = ? OR friend_id = ?) AND confirmed = ?',
                     self.id,
                     self.id,
                     other_user.id,
                     other_user.id,
                     true
    ).exists?
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
    SportSessionParticipant.where(:user_id => self.id, :sport_session_id => sport_session_id).exists?
  end

  def sport_sessions_confirmed(type='')
    SportSession.all_sport_sessions_confirmed_from_user(self.id, type)
  end

  def sport_sessions_unconfirmed(type='')
    SportSession.all_sport_sessions_unconfirmed_from_user(self.id, type)
  end

end
