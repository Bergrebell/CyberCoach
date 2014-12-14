class CyclingsController < SportSessionsController

  # List all running sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    @cyclings_upcoming = current_user.sport_sessions_filtered(params, true, 'Cycling').select { |s| s.is_upcoming }
    @cyclings_past = current_user.sport_sessions_filtered(params, true, 'Cycling').select { |s| s.is_past }
    @invitations = current_user.sport_sessions_filtered(params, false, 'Cycling')
  end

  def new
    @cycling = Facade::SportSession::Cycling.create(user: current_user, type: 'Cycling')
  end


  def edit
    @cycling = Facade::SportSession::Cycling.find_by id: params[:id]
  end


  # GET /cyclings/:id/result/edit
  # Edit result
  #
  def edit_result
    begin
      @cycling = Facade::SportSession::Cycling.find_by id: params[:id]

      if not @cycling.is_participant(current_user)
        redirect_to cyclings_url, alert: 'Permission denied'
      end

      if @cycling.date > Date.today
        redirect_to cyclings_url, alert: 'Storing results only possible if event is passed'
      end

      @result = @cycling.result(current_user)
    rescue
      redirect_to cyclings_url, alert: 'Permission denied'
    end
  end


  # POST /cyclings/:id/result/save
  # Save a result for current user
  #
  def save_result
    @cycling = Facade::SportSession::Cycling.find_by id: params[:id]

    if not @cycling.is_confirmed_participant(current_user)
      redirect_to cyclings_url, alert: 'Permission denied'
    end

    @result = @cycling.result(current_user)

    # read gpx file if present
    track = nil
    if results_params[:file].present?
      @result = Track.create_track_and_update_result(@result, results_params[:file])
      track = @result.track
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

      redirect_to cyclings_url
    else
      flash[:notice] =  'Unable to save results'
      render :edit_result
    end

  end


  def show
    @track = begin
      track = Track.find_by!(user_id: @user.id, sport_session_id: params[:id])
      track.read_track_data
    rescue
      Track::TrackDataContainer.new
    end
    @cycling = Facade::SportSession::Cycling.find_by id: params[:id]
  end


  # POST /cyclings
  def create
    @cycling = Facade::SportSession::Cycling.create(cycling_params)
    if @cycling.save
      redirect_to cyclings_url, notice: 'Cycling session successfully created'
    else
      render :new
    end
  end


  def update
    @cycling = Facade::SportSession::Cycling.find_by id: params[:id]
    if @cycling.update(cycling_params)
      redirect_to cyclings_url, notice: 'Cycling session successfully updated'
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

  private

  def cycling_params
    sport_session_params('cycling')
  end

end
