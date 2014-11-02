class RunningsController < ApplicationController


  # List all running sessions
  def index
    @sessions = Facade::SportSession.where user_id: current_user.id # pretty cool hehehe...don't get used to it :-)
    @friends = current_user.friends
  end

  def new

  end


  def edit
    @running = Facade::SportSession.find_by id: params[:id]
  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create
    entry_params = params.merge({facade_user: current_user, type: 'Running'})
    entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
    @entry = Facade::SportSession.create entry_params
    if auth_proxy.save(@entry)
      redirect_to runnings_url, notice: 'Running session successfully created'
    else
      flash[:notice] = 'Unable to create Running session'
      render :new
    end
  end


  def update
    @running = Facade::SportSession.find_by id: params[:id]
    entry_params = sport_session_params.merge({facade_user: current_user, type: 'Running'})
    @running.update_attributes(entry_params)
    if auth_proxy.update(@running)
      redirect_to runnings_url, notice: 'Running session successfully updated'
    else
      render :edit
    end
  end


  def destroy

  end

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

end
