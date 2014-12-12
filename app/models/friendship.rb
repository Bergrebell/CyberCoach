class Friendship < ActiveRecord::Base

  validates :user_id, presence: true
  validates :friend_id, presence: true


  def confirm
    self.confirmed = true
    save
  end

  def decline
    destroy
  end

  # Return the friendship object of two users
  #
  def self.from_users(user_id, friend_id)
    Friendship.where('(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)', user_id, friend_id, friend_id, user_id).first
  end

end
