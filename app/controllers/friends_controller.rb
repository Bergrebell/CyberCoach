class FriendsController < ApplicationController

  before_action :set_current_user
  
  def index
    @friends = @current_user.friends
    @requests_received = @current_user.received_friend_requests
    users = RestAdapter::User.all query: {size: 10 }
    @proposals = users.select {|u| @current_user.not_befriended_with?(u)}
  end


  def proposals
    @friend_proposals = current_user.sent_friend_requests
  end


  # Conform a friend request
  # POST
  #
  def confirm
    other_user = RestAdapter::User::retrieve params[:username]
    partnership = RestAdapter::Partnership.retrieve(
      first_user: other_user,
      second_user: current_user,
    )
    if partnership.present?
      if auth_proxy.save(partnership)
        redirect_to friends_index_url, notice: 'You are now friend with %s' % params[:username] and return
      else
        redirect_to friends_index_url, alert: 'Could not confirm friend request' and return
      end
    else
      redirect_to friends_index_url, alert: 'Friend request not found'
    end
  end

  # Send a friend request
  # POST
  #
  def create
    other_user = RestAdapter::User::retrieve params[:username]

    partnership = RestAdapter::Partnership.new(
        first_user: current_user,
        second_user: other_user,
        public_visible: RestAdapter::Privacy::Public
    )

    respond_to do |format|
      if auth_proxy.save(partnership) # if validation is ok, try to create the partnership
        format.html { redirect_to friends_index_url, notice: 'Friend request is sent to %s.' % params[:username]  }
      else
        format.html { redirect_to friends_index_url, alert: 'Friend request failed! Cyber Coach server is bitchy.'  }
      end
    end
  end


  # Use callbacks to share common setup or constraints between actions.
  def set_current_user
    @current_user = current_user
  end

end
