class UsersController < ApplicationController
  skip_before_action :require_login
  
  before_action :require_login, only: [:update, :edit]

  # GET /users
  # GET /users.json
  def index
    @users = Facade::User.paginate(per_page: 5, page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    begin
      @user = Facade::User.query do
        User.find_by id: params[:id]
      end
      @friends = @user.friends
    rescue
      redirect_to users_path
    end
    gravatar_id = Digest::MD5.hexdigest(@user.email.downcase)
    @gravatar_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=125&d"
    @upcoming_activities = @user.sport_sessions_confirmed.where('date >= ?', Date.today).limit(3)  #TODO: refactor this
    @sports_past = @user.sport_sessions_confirmed.where('date < ?', Date.today).limit(3)  #TODO: refactor this
  end

  # GET /users/new
  def new
    @user = Facade::User.create
  end

  # GET /users/1/edit
  def edit
    if params[:id] == current_user.username
      @user = current_user
    else
      flash[:notice] = 'Hey buddy! You cannot change an account of someone else!'
      redirect_to welcome_index_path
    end
  end

  # POST /users
  # POST /users.json
  def create
    # create a cyber coach user
    @user = Facade::User.create(user_params)
    if @user.save # if validation is ok, try to create the user
      # auto login, after registration
      session[:username] = @user.username
      session[:password] = @user.password
      redirect_to welcome_index_path, notice: 'User was successfully created.'
    else
      flash[:notice] = 'Could not register. Cyber coach server is bitchy today!'
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to welcome_index_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = Facade::User.retrieve(params[:id])
    #do nothing for now: @user.delete
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end




  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :email, :real_name, :location, :latitude, :longitude)
  end
end
