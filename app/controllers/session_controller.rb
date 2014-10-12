class SessionController < ApplicationController

  skip_before_action :require_login

  def login
    if params[:username].present? and params[:password].present?
      # if okay, user is an object and evaluates to true
      if user = User.authenticate(params[:username], params[:password])
        # The username key the session is basically the proof that the user is authenticated for further requests
        session[:user] = user
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
