class SessionController < ApplicationController

  skip_before_action :require_login

  def login
    if params[:username].present? and params[:password].present?
      user = Facade::User.authenticate(params.dup)
      if user
        session[:username] = user.username
        session[:password] = user.password
        ObjectStore::Store.set(user.username, user) # store logged in user as facade user in the object store
        redirect_to '/welcome/index', notice: 'Logged in successfully'
      else
        flash[:error] = 'User credentials not valid'
      end
    end
  end

  def logout
    user = ObjectStore::Store.get(session[:username])
    ObjectStore::Store.remove(session[:username])
    session[:username] = nil
    session[:password] = nil
    redirect_to '/welcome/index', notice: 'Logged out successfully'
  end

end
