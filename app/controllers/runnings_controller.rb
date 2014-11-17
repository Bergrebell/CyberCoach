class RunningsController < ApplicationController


  # List all running sessions
  def index
    # Grab all the running sessions where the current user is a participant
    runnings = SportSession.confirmed_sessions_from_user(current_user.id, 'Running')
    @runnings_upcoming = runnings.select { |running| Date.parse(running.date.to_s) > Date.today}
    @runnings_past = runnings.select { |running| Date.parse(running.date.to_s) < Date.today}
    @invitations = SportSession.unconfirmed_sessions_from_user(current_user.id, 'Running')
  end

  def new
    @running = Facade::SportSession.create(user: current_user, type: 'Running')
    @friends = current_user.friends # TODO This should return users of type Facade?
  end


  def edit
    @running = Facade::SportSession.find_by id: params[:id]

    if Date.parse(@running.entry_date) < Date.today
      # Can only edit results
      @results = @running.sport_session_participants.where(:user_id => current_user.id).first!.result
      render :edit_results
    else
      # Normal edit
      @friends = current_user.friends
      render :edit
    end


  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create

    date_time_object = DateTime.strptime(sport_session_params[:entry_date], '%Y-%m-%d')
    entry_params = sport_session_params.merge({user: current_user, type: 'Running', entry_date: date_time_object})

    # Workaround, we actually need the user ID and not username. We'll fix this later
    ################################################################################
    users_invited = []
    if entry_params[:users_invited].present?
      entry_params[:users_invited].each do |username|
        user = User.where(:name => username).first
        if user.present?
          users_invited.push(user.id)
        end
      end
    end
    entry_params[:users_invited] = users_invited
    ################################################################################


    # @wanze => this is a one-liner :-)
    # entry_params[:users_invited] = User.select(:id).where('name in (?)', entry_params[:users_invited])

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

    if Date.parse(@running.entry_date) < Date.today

      # Save result
      @results = @running.sport_session_participants.where(:user_id => current_user.id).first!.result
      @results.length = results_params[:length]
      @results.time = results_params[:time]

      @results.save

      # TODO Check for achievements

      redirect_to runnings_url, notice: 'Saved details'

    else

      # Update entry
      entry_params = sport_session_params.merge({user: current_user, type: 'Running'})
      if @running.update(entry_params)
        redirect_to runnings_url, notice: 'Running session successfully updated'
      else
        render :edit
      end
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

  def results_params
    params[:results]
  end

end
