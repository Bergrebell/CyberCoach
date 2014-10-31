class SessionController < ApplicationController

  skip_before_action :require_login

  def login
    if params[:username].present? and params[:password].present?
      # if okay, user is an object and evaluates to true
      if user = Facade::User.authenticate(params.dup)
        # get a hash of the user object, because rails cannot store objects in a session.
        # the rails session is just a key value store...

        session[:username] = user.username
        session[:password] = user.password
        session[:remote_ip] = request.remote_ip
        ObjectStore::Store.set(user.username, user)
        redirect_to '/welcome/index', notice: 'Logged in successfully'
      else
        flash[:error] = 'User credentials not valid'
      end
    end
  end

  def logout
    ObjectStore::Store.remove(session[:username])
    session[:username] = nil
    session[:password] = nil
    redirect_to '/welcome/index', notice: 'Logged out successfully'
  end

end
