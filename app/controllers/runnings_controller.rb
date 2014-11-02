class RunningsController < ApplicationController


  # List all running sessions
  def index
    @sessions = Facade::SportSession.where user_id: current_user.id # pretty cool hehehe...don't get used to it :-)
    @friends = current_user.friends
  end

  def new
    @running = Running.new
  end


  def edit
    @running = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
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


  def update
    @running = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({facade_user: current_user, type: 'Running'})
    @running.update_attributes(entry_params)
    if auth_proxy.update(@running)
      redirect_to welcome_index_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end


  def destroy

  end

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

end
