class SportSessionsController < ApplicationController

  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    # If sessions must be filtered, use the passed params for filtering
    # display all confirmed sessions otherwise
    if params.count > 0
      @sessions_upcoming = current_user.sport_sessions_filtered(params, true).select { |s| s.is_upcoming }
      @sessions_past = current_user.sport_sessions_filtered(params, true).select { |s| s.is_past }
      @invitations = current_user.sport_sessions_filtered(params, false)
    else
      sessions = current_user.sport_sessions_confirmed
      @sessions_upcoming = sessions.select { |s| s.is_upcoming }
      @sessions_past = sessions.select { |s| s.is_past }
      @invitations = current_user.sport_sessions_unconfirmed
    end
  end


  def show
    # We redirect to the correct type, this is possible due to single table inheritance returning the correct object
    @session = SportSession.find_by id: params[:id]
    redirect_to polymorphic_path(@session, user_id: params[:user_id]) #don't ask me, it does the job!
  end


  def edit
    @session = SportSession.find params[:id]
    redirect_to @session, action: 'edit'
  end


  # Confirm attendance to sport session
  #
  def confirm
    if params[:user_id] != current_user.id
      false
    end

    participant = SportSessionParticipant.where(:user_id => params[:user_id], :sport_session_id => params[:sport_session_id]).first!
    participant.confirmed = true
    if participant.save
      redirect_to sport_sessions_url, :notice => "Successfully subscribed to #{participant.sport_session.type} event, have fun!"
    else
      redirect_to sport_sessions_url, :alert => "Unable to confirm invitation"
    end

    false
  end


  # Decline attendance to sport session
  #
  def decline
    if params[:user_id] != current_user.id
      false
    end

    participant = SportSessionParticipant.where(:user_id => params[:user_id], :sport_session_id => params[:sport_session_id]).first!
    if participant.destroy
      redirect_to sport_sessions_url, :notice => "Invitation declined"
    else
      redirect_to sport_sessions_url, :alert => "Unable to decline invitation"
    end

    false
  end


  # Unsubscribe from an event by deleting the SportSessionParticipant object
  #
  def unsubscribe
    if params[:user_id] != current_user.id
      false
    end

    participant = SportSessionParticipant.where(:user_id => params[:user_id], :sport_session_id => params[:sport_session_id]).first!
    if participant.destroy
      redirect_to sport_sessions_url, :notice => "Successfully unsubscribed from the session"
    else
      redirect_to sport_sessions_url, :alert => "Unable to unsubscribe from event"
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

  def sport_session_params(type)
    a_hash = Hash[params[type].map {|k,v| [k.to_sym,v]}]
    a_hash[:user] = current_user
    a_hash
  end


  def results_params
    params.require(:sport_session_result).permit(:time, :length, :file)
  end


  def set_friends
    @friends = current_user.friends rescue []
  end


  def set_user
    @user = Facade::User.query do
      user = User.find_by id: params[:user_id]
      user ||= current_user
    end
    @user
  end

end
