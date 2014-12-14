class BoxingsController < SportSessionsController

  # List all running sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    @boxings_upcoming = current_user.sport_sessions_filtered(params, true, 'Boxing').select { |s| s.is_upcoming }
    @boxings_past = current_user.sport_sessions_filtered(params, true, 'Boxing').select { |s| s.is_past }
    @invitations = current_user.sport_sessions_filtered(params, false, 'Boxing')
  end


  def new
    @boxing = Facade::SportSession::Boxing.create(user: current_user)
  end


  def edit
    @boxing = Facade::SportSession::Boxing.find_by id: params[:id]
  end


  def show
    @boxing = Facade::SportSession::Boxing.find_by id: params[:id]
  end


  # GET /boxings/:id/result/edit
  # Edit result
  #
  def edit_result
    begin
      @boxing = Facade::SportSession::Boxing.find_by id: params[:id]

      if not @boxing.is_participant(current_user)
        redirect_to boxings_url, alert: 'Permission denied'
      end

      if @boxing.date > Date.today
        redirect_to boxings_url, alert: 'Storing results only possible if event is passed'
      end

      @result = @boxing.result(current_user)
    rescue
      redirect_to boxings_url, alert: 'Permission denied'
    end
  end

  # GET /boxings/:id/result/save
  # Save result
  #
  def save_result
    @boxing = Facade::SportSession::Boxing.find_by id: params[:id]

    if not @boxing.is_confirmed_participant(current_user)
      redirect_to boxings_url, alert: 'Permission denied'
    end

    @result = @boxing.result(current_user)
    @result.assign_attributes(results_params)

    if @result.save
      # Check for new Achievements!
      achievement_checker = AchievementsChecker.new @result
      achievements = achievement_checker.check true
      if achievements.count > 0
        titles = '"' + achievements.map { |a| a.achievement.title }.join('", "') + '"'
        flash[:notice] = ["Congratulations, you obtained new achievements: #{titles}"]
        flash[:notice] << 'Successfully saved results'
      else
        flash[:notice] = 'Successfully saved results'
      end

      redirect_to boxings_url
    else
      render :edit_result
    end

  end


  # POST /boxings
  def create
    @boxing = Facade::SportSession::Boxing.create(boxing_params)
    if @boxing.save
      redirect_to boxings_url, notice: 'Boxing session successfully created'
    else
      render :new
    end
  end


  def update
    @boxing = Facade::SportSession.find_by id: params[:id]
    if @boxing.update(boxing_params)
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


  private

  def boxing_params
    sport_session_params('boxing')
  end

end
