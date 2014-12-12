class FriendsController < ApplicationController

  before_action :require_login

  def index
    @friends = current_user.friends
    @requests_received = current_user.received_friend_requests
    @proposals = current_user.friends_proposals
  end

  def browse
    @users = User.paginate(per_page: 5, page: params[:page])
  end

  # Conform a friend request
  # POST
  #
  def confirm_decline
    friend_id = friendship_params[:friend_id]
    friendship = Friendship.from_users current_user.id, friend_id
    if friendship.present?
      if params.has_key?('confirm')
        confirm(friendship)
      elsif params.has_key?('decline')
        decline(friendship)
      end
    else
      redirect_to friends_index_url, alert: 'Friend request not found'
    end
  end

  # Send a friend request
  # POST
  #
  def create
    username, friend_id = friendship_params[:username], friendship_params[:friend_id]
    params = {user_id: current_user.id, friend_id: friend_id, confirmed: false}
    friendship = Friendship.where(params).first_or_initialize(params)

    respond_to do |format|
      if friendship.save
        format.html { redirect_to friends_index_url, notice: 'Friend request is sent to %s.' % username }
      else
        format.html { redirect_to friends_index_url, alert: 'Friend request failed!' }
      end
    end
  end

  private

  def confirm(friendship)
    if friendship.confirm
      redirect_to friends_index_url, notice: 'You are now friend with %s' % friendship_params[:username]
    else
      redirect_to friends_index_url, alert: 'Could not confirm friend request'
    end
  end

  def decline(friendship)
    if friendship.decline
      redirect_to friends_index_url, notice: 'You decline friend request from %s' % friendship_params[:username]
    else
      redirect_to friends_index_url, alert: 'Could not decline friend request'
    end
  end

  def friendship_params
    params.require(:friendship)
  end

end
