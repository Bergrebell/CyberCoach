class RunningsController < ApplicationController


  # List all running sessions
  def index
    @sessions = current_user.sport_sessions
    @friends = current_user.friends
  end

  def new
    @running = Running.new
  end


  # POST /users
  # POST /users.json
  def create
    # create a cyber coach user
    entry_params = params.merge({facade_user: current_user, type: 'Running'})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create entry_params
    if auth_proxy.save(@entry) # if validation is ok, try to create the user
      redirect_to welcome_index_path, notice: 'User was successfully created. '
    else
      flash[:notice] = 'Could not register. Cyber coach server is bitchy today!'
      render :new
    end
  end

  def show

  end

  def edit

  end

  def destroy

  end


end
