class FriendsController < ApplicationController

  
  def index
    @friends = current_user.friends
  end

  def requests
    @friend_requests = current_user.received_friend_requests
  end

  def proposals
    @friend_proposals = current_user.sent_friend_requests
  end


  def create
    other_user = RestAdapter::User::retrieve params[:id]

    partnership = RestAdapter::Partnership.new(
        first_user: current_user,
        second_user: other_user,
        public_visible: RestAdapter::Privacy::Public
    )

    respond_to do |format|
      if current_user.save(partnership) # if validation is ok, try to create the user
        format.html { redirect_to user_path(params[:id]), notice: 'Friend request is sent to %s.' % params[:id]  }
      else
        format.html { redirect_to user_path(params[:id]), notice: 'Friend request failed! Cyber Coach server is bitchy.'  }
      end
    end
  end

end
