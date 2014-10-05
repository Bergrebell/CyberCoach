class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = 'User is saved!'
      redirect_to users_index_path
    else
      flash[:notice] = 'Could not create user!'
      redirect_to users_new_path
    end

  end

  def user_params
    params.require(:user).permit(:username,:password,:realname,:email,:publicvisible)
  end

end
