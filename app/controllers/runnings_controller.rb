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

    if results_params[:file].present?
      gpx_xml = File.open(results_params[:file].tempfile) { |file| file.read }
      track_hash = gpx_to_hash gpx_xml
    end

    @result = @running.result(current_user)

    @result.time = track_hash[:stats][:time].nil? ? results_params[:time] : track_hash[:stats][:time]
    @result.length = track_hash[:stats][:distance].nil? ? results_params[:length] : track_hash[:stats][:distance]

    if @result.save
      # save uploaded file content
      #TODO: refactor the following if block and put into a method or something like that.
      if track_hash
        participant_id, user_id, sport_session_id = @result.sport_session_participant.id, @result.sport_session_participant.user_id, @result.sport_session_participant.sport_session_id
        track = Track.where(sport_session_participant_id: participant_id, user_id: user_id, sport_session_id: sport_session_id).first_or_initialize
        File.open(results_params[:file].tempfile) do |file|
          gpx_xml = file.read
          track.raw_data = gpx_xml
          track.data = track_hash.to_json
          track.format = File.extname results_params[:file].original_filename
          track.save
        end
      end

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
    #TODO: refactor this and integrate it with the sport session results
    track = Track.find_by user_id: current_user.id, sport_session_id: params[:id]
    if track.present? && track.data.present?
      json_to_vars(track.data)
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


  def gpx_to_hash(xml)
    track_reader = GPX::TrackReader.new(xml)
    {
        points: track_reader.points,
        center_of_gravity: track_reader.center_of_gravity,
        heights: track_reader.heights,
        paces: track_reader.paces,
        speeds: track_reader.speeds,
        stats: track_reader.stats
    }
  end


  def json_to_vars(json)
    begin
      a_hash = JSON.parse(json, symbolize_names: true)
      @points = a_hash[:points]
      @stats = a_hash[:stats]
      @heights = a_hash[:heights]
      @gravity_point = a_hash[:center_of_gravity]
      @speeds = a_hash[:speeds]
      @paces = a_hash[:paces]
    rescue
      # do nothing
    end
  end

end
