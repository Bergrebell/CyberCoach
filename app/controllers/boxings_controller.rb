class BoxingsController < ApplicationController


  # List all running sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    # If sessions must be filtered, use the passed params for filtering
    # display all running sessions otherwise, upcoming, past or unconfirmed, respectively.
    if params.count > 0
      @boxings_upcoming = current_user.sport_sessions_filtered(params, true, 'Boxing').select { |s| s.is_upcoming }
      @boxings_past = current_user.sport_sessions_filtered(params, true, 'Boxing').select { |s| s.is_past }
      @invitations = current_user.sport_sessions_filtered(params, false, 'Boxing')
    else
      boxings = current_user.sport_sessions_confirmed('Boxing')
      @boxings_upcoming = boxings.select { |s| s.is_upcoming }
      @boxings_past = boxings.select { |s| s.is_past }
      @invitations = current_user.sport_sessions_unconfirmed('Boxing')
    end
  end

  def new
    @boxing = Facade::SportSession.create(user: current_user, type: 'Boxing')
  end


  def edit
    @boxing = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @boxing = Facade::SportSession.find_by id: params[:id]
  end


  # POST /boxings
  def create
    date_time_object = DateTime.strptime(params[:date], Facade::SportSession::DATETIME_FORMAT)
    entry_params = params.merge({user: current_user, type: 'Boxing', entry_date: date_time_object})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create(entry_params)
    if @entry.save
      redirect_to boxings_url, notice: 'Boxing session successfully created'
    else
      flash[:notice] = 'Unable to create Boxing session'
      render :new
    end
  end


  def update
    @boxing = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({user: current_user, type: 'Boxing'})
    if @boxing.update(entry_params)
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

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

end
