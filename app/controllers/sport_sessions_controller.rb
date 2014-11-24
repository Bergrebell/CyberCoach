class SportSessionsController < ApplicationController

  def index
    # All confirmed sessions of the current user and their participants, used to display the filter values
    @all_sessions = current_user.sport_sessions_confirmed
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions

    # If sessions must be filtered, use the passed params for filtering the confirmed sessions
    # display all confirmed sessions otherwise
    if params.count > 0
      @sessions = current_user.sport_sessions_filtered(params)
    else
      @sessions = current_user.sport_sessions_confirmed
    end
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
