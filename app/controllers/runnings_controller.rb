class RunningsController < SportSessionsController


  # List all running sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    # If sessions must be filtered, use the passed params for filtering
    # display all running sessions otherwise, upcoming, past or unconfirmed, respectively.
    if params.count > 0
      @runnings_upcoming = current_user.sport_sessions_filtered(params, true, 'Running').select { |s| s.is_upcoming }
      @runnings_past = current_user.sport_sessions_filtered(params, true, 'Running').select { |s| s.is_past }
      @invitations = current_user.sport_sessions_filtered(params, false, 'Running')
    else
      runnings = current_user.sport_sessions_confirmed('Running')
      @runnings_upcoming = runnings.select { |s| s.is_upcoming }
      @runnings_past = runnings.select { |s| s.is_past }
      @invitations = runnings_user.sport_sessions_unconfirmed('Running')
    end
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

    # read gpx file if present
    if results_params[:file].present?
      participant_id, user_id, sport_session_id = @result.sport_session_participant.id, @result.sport_session_participant.user_id, @result.sport_session_participant.sport_session_id
      track = Track.where(sport_session_participant_id: participant_id, user_id: user_id, sport_session_id: sport_session_id).first_or_initialize
      track_data_container = track.store_gpx_file(results_params[:file])
      # set result values
      @result.time = track_data_container.statistics(:total_time).nil? ? results_params[:time] : track_data_container.statistics(:total_time)
      @result.length = track_data_container.statistics(:total_distance).nil? ? results_params[:length] : track_data_container.statistics(:total_distance)
    else
      @result.time = results_params[:time]
      @result.length = results_params[:length]
    end


    if @result.save
      track.save if track.present?

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
    @track = begin
      track = Track.find_by!(user_id: current_user.id, sport_session_id: params[:id])
      track.read_track_data
    rescue
      Track::TrackDataContainer.new
    end

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
    params.require(:sport_session_result).permit(:time, :length, :file)
  end


end
