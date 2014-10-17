class SessionController < ApplicationController

  skip_before_action :require_login

  def login
    if params[:username].present? and params[:password].present?
      # if okay, user is an object and evaluates to true
      if user = RestAdapter::User.authenticate(params)
        # get a hash of the user object, because rails cannot store objects in a session.
        # the rails session is just a key value store...
        session[:user] = user.as_hash
        session[:remote_ip] = request.remote_ip

        redirect_to '/welcome/index', notice: 'Logged in successfully'
      else
        flash[:error] = 'User credentials not valid'
      end
    end
  end

  def logout
    session[:user] = nil
    redirect_to '/welcome/index', notice: 'Logged out successfully'
  end

end
