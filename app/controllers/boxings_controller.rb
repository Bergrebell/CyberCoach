class BoxingsController < ApplicationController


  # List all running sessions
  def index
    @sessions = Facade::SportSession.where(user_id: current_user.id, type: 'Boxing') # pretty cool hehehe...don't get used to it :-)
    @friends = current_user.friends
  end

  def new

  end


  def edit
    @boxing = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @boxing = Facade::SportSession.find_by id: params[:id]
  end


  # POST /boxings
  def create
    entry_params = params.merge({user: current_user, type: 'Boxing'})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create(entry_params)
    if @entry.save
      redirect_to boxings_url, notice: 'Boxing session successfully created'
    else
      flash[:notice] = 'Unable to create Boxing session'
      render :new
    end
  end


  def update
    @boxing = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({user: current_user, type: 'Boxing'})
    if @boxing.update(entry_params)
      redirect_to boxings_url, notice: 'Boxing session successfully updated'
    else
      render :edit
    end
  end


  def destroy
    @session = Facade::SportSession.find_by id: params[:id]
    if @session.delete
      redirect_to sport_sessions_index_path, notice: 'Sport session was successfully destroyed.'
    else
      redirect_to sport_sessions_index_path, notice: 'Sport session cannot be removed.'
    end
  end

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

end
