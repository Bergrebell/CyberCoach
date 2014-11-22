class RunningsController < SportSessionsController


  # List all running sessions
  def index
    # Grab all the running sessions where the current user is a participant
    runnings = current_user.sport_sessions_confirmed('Running')
    @runnings_upcoming = runnings.select { |running| running.date > Date.today}
    @runnings_past = runnings.select { |running| running.date < Date.today}
    @invitations = current_user.sport_sessions_unconfirmed('Running')
  end

  def new
    @running = Facade::SportSession::Running.create(user: current_user)
    @friends = current_user.friends
  end


  def edit
    @running = Facade::SportSession::Running.find_by id: params[:id]
    if @running.user_id != current_user.id
      redirect_to runnings_url, alert: 'Permission denied'
    end
    @friends = current_user.friends
  end


  def edit_result
    @running = Facade::SportSession::Running.find_by id: params[:id]
    # TODO Get result object
  end


  def save_result
    # TODO
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
      flash[:alert] = 'Unable to create Running session'
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
    sport_session_params('running') # Delegates to method on superclass (SportSessionController)
  end

  def results_params
    params[:results]
  end

end
