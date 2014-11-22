class FriendsController < ApplicationController

  before_action :require_login

  def index
    @friends = current_user.friends
    @requests_received = current_user.received_friend_requests
    # users = Facade::User.query do
    #   User.all
    # end
    @proposals = current_user.friends_proposals
  end


  def proposals
    @friend_proposals = current_user.sent_friend_requests
  end


  # Conform a friend request
  # POST
  #
  def confirm
    proposer = Facade::User.retrieve params[:username]
    partnership = Facade::Partnership.retrieve(
      confirmer: current_user,
      proposer: proposer,
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
    other_user = Facade::User.retrieve params[:username]

    raise 'errorror' if current_user.is_a?(RestAdapter::Models::User)
    partnership = Facade::Partnership.create(
        proposer: current_user,
        confirmer: other_user
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
