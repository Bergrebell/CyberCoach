class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants


  # Invite some users to join this event
  # @param array user_ids
  #
  def invite(user_ids)

    if not user_ids.kind_of?(Array)
      return
    end

    # Remove any records not confirmed first
    sessions_participants = SportSessionParticipant.where(:sport_session_id => self.id, :confirmed => false)
    sessions_participants.each do |session_participant|
      session_participant.destroy
    end

    # Create SportSessionParticipant objects if not existing
    user_ids.each do |user_id|
      SportSessionParticipant.where(:sport_session_id => self.id, :user_id => user_id).first_or_create(:confirmed => false)
    end

  end

  # Return all SportSessions where the given user participated
  #
  def self.all_sessions_from_user(user_id, type='', confirmed=nil)
    where = {:user_id => user_id}
    if not confirmed.nil?
      where[:confirmed] = confirmed
    end
    if type.present?
      SportSession.where(:type => type).joins(:sport_session_participants).where(sport_session_participants: where)
    else
      SportSession.joins(:sport_session_participants).where(sport_session_participants: where)
    end

  end


  def self.all_sport_sessions_confirmed_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, true)
  end

  def self.all_sport_sessions_unconfirmed_from_user(user_id, type='')
    self.all_sessions_from_user(user_id, type, false)
  end

  # find the given user's sport sessions based on filters (copied from Stefan's CarTrading filter for offers)
  def self.all_sport_sessions_filtered_from_user(user_id, params)
    user = {user_id: user_id}
    filter = {}

    if params[:type].present?
      type = {type: params[:type]}
      filter.merge!(type)
    end

    if params[:entry_location].present?
      location = {location: params[:entry_location]}
      filter.merge!(location)
    end

    if params[:date].present?
      date_time_object = DateTime.strptime(params[:date], Facade::SportSession::DATETIME_FORMAT)
      date = {date: date_time_object}
      filter.merge!(date)
    end

    filtered_sessions = SportSession.where(filter).joins(:sport_session_participants).where(sport_session_participants: user)

    if params[:participant].present?
      participant = {user_id: params[:participant]}
      filtered_sessions = filtered_sessions.joins(:sport_session_participants).where(sport_session_participants: participant)
    else
      filtered_sessions
    end

  end

end
