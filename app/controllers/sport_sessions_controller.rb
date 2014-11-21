class SportSessionsController < ApplicationController


  def index
    @sessions = current_user.sport_sessions_confirmed
  end

  def show
    @session = Facade::SportSession.find_by id: params[:id]
  end

  def edit
    @session = Facade::SportSession.find_by id: params[:id]
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
      case participant.sport_session.type
        when 'Running'
          redirect_to runnings_url, :notice => 'Successfully subscribed to running event, have fun!'
        when 'Boxing'
          redirect_to boxings_url, :notice => 'Successfully subscribed to boxing event, have fun!'
        when 'Cycling'
          redirect_to cyclings_url, :notice => 'Successfully subscribed to cycling event, have fun!'
        when 'Soccer'
          recirect_to soccer_url, :notice => 'Successfully subscribed to soccer event, have fun!'
      end
    end

    false
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