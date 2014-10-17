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

end
