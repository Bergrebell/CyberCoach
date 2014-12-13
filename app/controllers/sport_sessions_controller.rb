class SportSessionsController < ApplicationController

  before_action :check_view_permission, :except => [:index, :confirm, :decline]
  before_action :check_edit_permission, :only => [:edit, :destroy, :update]
  before_action :check_confirm_decline_permissions, :only => [:confirm, :decline]
  before_action :check_unsubscribe_permission, :only => [:unsubscribe]


  before_action :set_friends, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :set_user, only: [:show]


  def index
    @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
    @sessions_upcoming = current_user.sport_sessions_filtered(params, true).select { |s| s.is_upcoming }
    @sessions_past = current_user.sport_sessions_filtered(params, true).select { |s| s.is_past }
    @invitations = current_user.sport_sessions_filtered(params, false)
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
    params.require(:sport_session_result).permit(:time, :length, :file, :knockout_opponent, :number_of_rounds, :points)
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

  # Basic permission check if the current logged in user is allowed to view the session
  #
  def check_view_permission
    @session = SportSession.find get_sport_session_id
    if not @session.is_viewable(current_user)
      redirect_to sport_sessions_index_path, alert: 'Permission denied'
    end
  end


  # Check edit permission
  #
  def check_edit_permission
    @session = SportSession.find get_sport_session_id
    if not @session.is_editable(current_user)
      redirect_to sport_sessions_index_path, alert: 'Permission denied'
    end
  end

  # Check confirm/decline permission
  #
  def check_confirm_decline_permissions
    @session = SportSession.find get_sport_session_id
    if not @session.is_confirmable(current_user) and params[:user_id] != current_user.id
      redirect_to sport_sessions_index_path, alert: 'Permission denied'
    end
  end

  def check_unsubscribe_permission
    @session = SportSession.find get_sport_session_id
    if not @session.is_unsubscribeable(current_user) and params[:user_id] != current_user.id
      redirect_to sport_sessions_index_path, alert: 'Permission denied'
    end
  end

  def get_sport_session_id
    if params[:id].present?
      params[:id]
    elsif params[:sport_session_id].present?
      params[:sport_session_id]
    else
      raise 'No SportSession ID found!'
    end
  end

end
