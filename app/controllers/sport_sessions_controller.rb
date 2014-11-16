class SportSessionsController < ApplicationController


  def index
    @sessions = SportSession.confirmed_sessions_from_user(current_user.id)
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
      redirect_to sport_sessions_index_path, notice: 'Sport session was successfully destroyed.'
    else
      redirect_to sport_sessions_index_path, notice: 'Sport session cannot be removed.'
    end
  end

end