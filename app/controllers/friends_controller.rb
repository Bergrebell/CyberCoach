class FriendsController < ApplicationController

  before_action :require_login

  def index
    @friends = current_user.friends
    @requests_received = current_user.received_friend_requests
    users = Facade::User.all query: {size: 10 }
    @proposals = current_user.friend_proposals(users)
  end


  def proposals
    @friend_proposals = current_user.sent_friend_requests
  end


  # Conform a friend request
  # POST
  #
  def confirm
    other_user = Facade::User::retrieve params[:username]
    partnership = Facade::Partnership.retrieve(
      first_user: other_user,
      second_user: current_user,
    )
    if partnership.present?
      if partnership.save
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
    other_user = Facade::User::retrieve params[:username]

    partnership = Facade::Partnership.new(
        first_user: current_user,
        second_user: other_user,
        public_visible: RestAdapter::Privacy::Public
    )

    respond_to do |format|
      if partnership.save # if validation is ok, try to create the partnership
        format.html { redirect_to friends_index_url, notice: 'Friend request is sent to %s.' % params[:username]  }
      else
        format.html { redirect_to friends_index_url, alert: 'Friend request failed! Cyber Coach server is bitchy.'  }
      end
    end
  end



end
