class RunningsController < ApplicationController


  # List all running sessions
  def index
    @runnings = Facade::SportSession.where(user_id: current_user.id, type: 'Running')
    @friends = current_user.friends
  end

  def new
    @running = Facade::SportSession.create(user: current_user, type: 'Running')
  end


  def edit
    @running = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create
    date_time_object = DateTime.strptime(params[:date], '%Y-%m-%d')
    entry_params = params.merge({user: current_user, type: 'Running', entry_date: date_time_object})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create(entry_params)
    if @entry.save
      redirect_to runnings_url, notice: 'Running session successfully created'
    else
      flash[:notice] = 'Unable to create Running session'
      render :new
    end
  end


  def update
    @running = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({user: current_user, type: 'Running'})
    if @running.update(entry_params)
      redirect_to runnings_url, notice: 'Running session successfully updated'
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
