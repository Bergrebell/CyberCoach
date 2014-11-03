class SportSessionsController < ApplicationController


  def index
    @sessions = Facade::SportSession.where user_id: current_user.id # pretty cool hehehe...don't get used to it :-)
  end

  def show
    @session = Facade::SportSession.find_by id: params[:id]
  end

  def edit
    @session = Facade::SportSession.find_by id: params[:id]
  end


  def destroy
    @session = Facade::SportSession.find_by id: params[:id]
    if @session.delete
      redirect_to sport_sessions_index_path, notice: 'Running session was successfully destroyed.'
    else
      redirect_to sport_sessions_index_path, notice: 'Running session cannot be removed.'
    end
  end

end