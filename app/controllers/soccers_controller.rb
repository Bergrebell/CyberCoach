class SoccersController < SportSessionsController

  before_action :set_friends, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :set_user, only: [:show]

  # List all soccer sessions
  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    # If sessions must be filtered, use the passed params for filtering
    # display all running sessions otherwise, upcoming, past or unconfirmed, respectively.
    if params.count > 0
      @soccers_upcoming = current_user.sport_sessions_filtered(params, true, 'Soccer').select { |s| s.is_upcoming }
      @soccers_past = current_user.sport_sessions_filtered(params, true, 'Soccer').select { |s| s.is_past }
      @invitations = current_user.sport_sessions_filtered(params, false, 'Soccer')
    else
      soccers = current_user.sport_sessions_confirmed('Soccer')
      @soccers_upcoming = soccers.select { |s| s.is_upcoming }
      @soccers_past = soccers.select { |s| s.is_past }
      @invitations = current_user.sport_sessions_unconfirmed('Soccer')
    end
  end


  def new
    @soccer = Facade::SportSession::Soccer.create(user: current_user)
  end


  def edit
    @soccer = Facade::SportSession::Soccer.find_by id: params[:id]
  end


  def show
    @soccer = Facade::SportSession::Soccer.find_by id: params[:id]
  end


  # POST /runnings
  def create
    @soccer = Facade::SportSession::Soccer.create(soccer_params)
    if @soccer.save
      redirect_to soccers_url, notice: 'Soccer session successfully created'
    else
      flash[:notice] = 'Unable to create Soccer session'
      render :new
    end
  end


  def update
    @soccer = Facade::SportSession::Soccer.find_by id: params[:id]
    if @soccer.update(soccer_params)
      redirect_to soccers_url, notice: 'Soccer session successfully updated'
    else
      render :edit
    end
  end


  def destroy
    @soccer = Facade::SportSession::Soccer.find_by id: params[:id]
    if @soccer.delete
      redirect_to sport_sessions_index_path, notice: 'Sport session was successfully destroyed.'
    else
      redirect_to sport_sessions_index_path, notice: 'Sport session cannot be removed.'
    end
  end

  private

  # Prepare parameters for create/update method
  #
  def soccer_params
    sport_session_params('soccer') # Delegates to method on superclass (SportSessionController)
  end


end
