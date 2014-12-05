class BoxingsController < SportSessionsController

  before_action :set_friends, only: [:show, :new, :create, :edit, :update, :destroy]

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
    @boxing = Facade::SportSession::Boxing.create(user: current_user)
  end


  def edit
    @boxing = Facade::SportSession::Boxing.find_by id: params[:id]
    raise 'Error' if @boxing.is_a? RestAdapter::Models::Entry
  end

  def show
    @user = Facade::User.query do
      user = User.find_by id: params[:user_id]
      user ||= current_user
    end
    @boxing = Facade::SportSession.find_by id: params[:id]
  end


  # POST /boxings
  def create
    @boxing = Facade::SportSession::Boxing.create(boxing_params)
    if @boxing.save
      redirect_to boxings_url, notice: 'Boxing session successfully created'
    else
      flash[:notice] = 'Unable to create Boxing session'
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

  def set_friends
    @friends = current_user.friends rescue []
  end

end
