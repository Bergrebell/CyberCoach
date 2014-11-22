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


  # Edit result
  #
  def edit_result
    # TODO Check that the current user is participant of object or catch exception
    @running = Facade::SportSession::Running.find_by id: params[:id]
    if @running.date > Date.today
      redirect_to runnings_url, alert: 'Storing results only possible if event is passed'
    end

    @result = @running.result(current_user)
  end


  # Save a result for current user
  #
  def save_result
    # TODO Check that the current user can save results or catch exception
    @running = Facade::SportSession::Running.find_by id: params[:id]
    @result = @running.result(current_user)

    @result.time = params[:time]
    @result.length = params[:length]
    if @result.save
      # TODO Check achievements
      redirect_to runnings_url, notice: 'Successfully saved results'
    else
      redirect_to runnings_url, alert: 'Unable to save results'
    end

  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create
    @running = Facade::SportSession::Running.create(running_params)

    if @running.save
      redirect_to runnings_url, notice: 'Running session successfully created'
    else
      flash[:alert] = 'Unable to create Running session'
      @friends = current_user.friends
      render :new
    end
  end


  def update
    @running = Facade::SportSession::Running.find_by id: params[:id]

    if @running.update(running_params)
      redirect_to runnings_url, notice: 'Running session successfully updated'
    else
      @friends = current_user.friends
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

  private

  # Prepare parameters for create/update method
  #
  def running_params
    sport_session_params('running') # Delegates to method on superclass (SportSessionController)
  end

  def results_params
    params[:results]
  end

end
