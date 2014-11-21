class RunningsController < ApplicationController


  # List all running sessions
  def index
    # Grab all the running sessions where the current user is a participant
    runnings = current_user.sport_sessions_confirmed('Running')
    @runnings_upcoming = runnings.select { |running| Date.parse(running.date.to_s) > Date.today}
    @runnings_past = runnings.select { |running| Date.parse(running.date.to_s) < Date.today}
    @invitations = current_user.sport_sessions_unconfirmed('Running')
  end

  def new
    @running = Facade::SportSession::Running.create(user: current_user)
    @friends = current_user.friends
  end


  def edit
    @running = Facade::SportSession::Running.find_by id: params[:id]
    @friends = current_user.friends
  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create
    @entry = Facade::SportSession::Running.create(running_params)

    if @entry.save
      redirect_to runnings_url, notice: 'Running session successfully created'
    else
      flash[:notice] = 'Unable to create Running session'
      render :new
    end
  end


  def update
    @running = Facade::SportSession::Running.find_by id: params[:id]

    if @running.update(running_params)
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

  # Prepare parameters for create/update method
  #
  def running_params
    _params = Hash[params[:running].map {|k,v| [k.to_sym,v]}]
    _params[:entry_date] = DateTime.strptime(_params[:entry_date] + ' ' + _params[:entry_time], '%Y-%m-%d %H:%M') # Where's this constant? ;)
    _params[:user] = current_user
    _params
  end

  def results_params
    params[:results]
  end

end
