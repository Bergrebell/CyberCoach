class SportSessionsController < ApplicationController


  def index
    sessions = current_user.sport_sessions_confirmed
    @sessions_upcoming = sessions.select { |s| s.date > Date.today}
    @sessions_past = sessions.select { |s| s.date < Date.today}
    @invitations = current_user.sport_sessions_unconfirmed

  end

  def show
    # We redirect to the correct type, this is possible due to single table inheritance returning the correct object
    @session = SportSession.find params[:id]
    redirect_to @session
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


  def sport_session_params(type)
    _params = Hash[params[type].map {|k,v| [k.to_sym,v]}]
    _params[:entry_date] = DateTime.strptime(_params[:entry_date] + ' ' + _params[:entry_time], '%Y-%m-%d %H:%M') # Where's this constant? ;)
    _params[:user] = current_user
    _params
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