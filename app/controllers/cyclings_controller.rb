class CyclingsController < SportSessionsController

  before_action :set_friends, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :set_user, only: [:show]

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
    @cycling = Facade::SportSession::Cycling.create(user: current_user, type: 'Cycling')
  end


  def edit
    @cycling = Facade::SportSession::Cycling.find_by id: params[:id]
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
      flash[:notice] = 'Unable to create Cycling session'
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
