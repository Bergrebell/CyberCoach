class CyclingsController < ApplicationController


  # List all running sessions
  def index
    @cyclings = Facade::SportSession.where(user_id: current_user.id, type: 'Cycling') # pretty cool hehehe...don't get used to it :-)
    @friends = current_user.friends
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


  # POST /runnings
  def create
    date_time_object = DateTime.strptime(params[:date], '%Y-%m-%d')
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
