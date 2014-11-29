class RunningsController < SportSessionsController


  # List all running sessions
  def index
    # Grab all the running sessions where the current user is a participant
    runnings = current_user.sport_sessions_confirmed('Running')
    @runnings_upcoming = runnings.select { |running| running.is_upcoming }
    @runnings_past = runnings.select { |running| running.is_past }
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


  # GET /runnings/:id/result/edit
  # Edit result
  #
  def edit_result
    @running = Facade::SportSession::Running.find_by id: params[:id]

    if not @running.is_participant(current_user)
      redirect_to runnings_url, alert: 'Permission denied'
    end

    if @running.date > Date.today
      redirect_to runnings_url, alert: 'Storing results only possible if event is passed'
    end

    @result = @running.result(current_user)
  end


  # POST /runnings/:id/result/save
  # Save a result for current user
  #
  def save_result
    @running = Facade::SportSession::Running.find_by id: params[:id]

    if not @running.is_confirmed_participant(current_user)
      redirect_to runnings_url, alert: 'Permission denied'
    end

    @result = @running.result(current_user)

    @result.time = results_params[:time]
    @result.length = results_params[:length]

    if @result.save

      # Check for new Achievements!
      achievement_checker = AchievementsChecker.new @result
      achievements = achievement_checker.check true
      if achievements.count > 0
        titles = '"' + achievements.map { |a| a.achievement.title}.join('", "') + '"'
        flash[:notice] = ["Congratulations, you obtained new achievements: #{titles}"]
        flash[:notice] << 'Successfully saved results'
      else
        flash[:notice] = 'Successfully saved results'
      end

      redirect_to runnings_url
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

    if not @running.user_id == current_user.id
      redirect_to runnings_url, alert: 'Permission denied'
    end

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
    params.require(:sport_session_result).permit(:time, :length)
  end

end
