class CyclingsController < ApplicationController


  # List all running sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    # If sessions must be filtered, use the passed params for filtering
    # display all running sessions otherwise, upcoming, past or unconfirmed, respectively.
    if params.count > 0
      @cyclings_upcoming = current_user.sport_sessions_filtered(params, true, 'Cycling').select { |s| s.is_upcoming }
      @cyclings_past = current_user.sport_sessions_filtered(params, true, 'Cycling').select { |s| s.is_past }
      @invitations = current_user.sport_sessions_filtered(params, false, 'Cycling')
    else
      cyclings = current_user.sport_sessions_confirmed('Cycling')
      @cyclings_upcoming = cyclings.select { |s| s.is_upcoming }
      @cyclings_past = cyclings.select { |s| s.is_past }
      @invitations = current_user.sport_sessions_unconfirmed('Cycling')
    end
  end

  def new
    @cycling = Facade::SportSession.create(user: current_user, type: 'Cycling')
  end


  def edit
    @cycling = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @cycling = Facade::SportSession.find_by id: params[:id]
  end


  # POST /cyclings
  def create
    date_time_object = DateTime.strptime(params[:date], Facade::SportSession::DATETIME_FORMAT)
    entry_params = params.merge({user: current_user, type: 'Cycling', entry_date: date_time_object})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create(entry_params)
    if @entry.save
      redirect_to cyclings_url, notice: 'Cycling session successfully created'
    else
      flash[:notice] = 'Unable to create Cycling session'
      render :new
    end
  end


  def update
    @cycling = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({user: current_user, type: 'Cycling'})
    if @running.update(entry_params)
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

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

end
