class SportSession < ActiveRecord::Base
  has_many :sport_session_participants
  has_many :users, through: :sport_session_participants
  belongs_to :user

  validates :title, presence: true
  validates :location, presence: true
  validates :entry_time, presence: true
  validates :entry_date, presence: true

  before_validation :check_if_subscription_is_available
  after_create :create_coach_entry

  after_find :load_coach_entry

  after_update :update_coach_entry


  # Virtual attributes

  def users_invited=(param)
    @users_invited = param
  end

  def users_invited
    @users_invited || []
  end

  def comment
    @comment
  end

  def comment=(param)
    @comment = param
  end

  def number_of_rounds=(param)
    @number_of_rounds = param
  end

  def number_of_rounds
    @number_of_rounds
  end

  def course_length=(param)
    @course_length = param
  end

  def course_length
    @course_length
  end

  def course_type=(param)
    @course_type = param
  end

  def course_type
    @course_type
  end

  def entry_duration
    @entry_duration
  end

  def entry_duration=(param)
    @entry_duration = param
  end

  #alias_method :entryduration=, :entry_duration=

  def round_duration=(param)
    @round_duration = param
  end

  def round_duration
    @round_duration
  end


  def entry_time(format=true)
    if date.present? && format
      date.strftime('%H:%M')
    else
      @entry_time
    end
  end


  def entry_time=(param)
    @entry_time = param
  end


  def entry_date(format=true)
    if date.present? && format
      date.strftime('%Y-%m-%d')
    else
      @entry_date
    end
  end


  def entry_date=(param)
    @entry_date = param
  end



  def proxy
    proxy = Coach4rb::Proxy::Access.new user.username, user.password, Coach
  end

  def coach_user
    coach_user = Coach.user user.username
  end

  def entry_type
    self.class.name.downcase.to_sym
  end

  def entry_properties
    [:comment, :entry_date, :entry_duration, :round_duration, :number_of_rounds, :course_length, :course_type]
  end


  # Callbacks

  def check_if_subscription_is_available
    begin
      Coach.subscription(self.user.username,self.type)
    rescue
      errors.add(:base, 'Cannot create entry %s! Subscription is missing!' % self.type)
      false
    end
  end

  def load_coach_entry
    entry = ObjectStore::Store.get([:coach_entry,self.id])
    if entry.nil?
      entry = Coach.entry_by_uri(self.cybercoach_uri)
      ObjectStore::Store.set([:coach_entry,self.id],entry)
      set_properties(entry)
    end
    set_properties(entry)
  end


  def set_properties(coach_entry)
    entry_properties.each do |prop|
      if coach_entry.respond_to?(prop)
        value = coach_entry.send prop
        self.send "#{prop}=".to_sym, value
      end
    end
  end


  def set_entry_values(entry)
    entry_properties.each do |prop|
      if self.send(prop).present?
        value = self.send(prop)
        entry.send "#{prop}=".to_sym, value
      end
    end
  end


  def create_coach_entry
    coach_entry = proxy.create_entry(coach_user, entry_type) do |entry|
      set_entry_values(entry)
    end

    if coach_entry
      date = merge_date(entry_date, entry_time)
      self.update_column(:cybercoach_uri, coach_entry.uri)
      self.update_column(:date, date)

      self.invite(users_invited)

      # The user creating the entry also needs a SportSessionParticipant object
      SportSessionParticipant.where(
          :user_id => self.user_id,
          :sport_session_id => self.id,
          :confirmed => true
      ).first_or_create
    else
      self.delete
      false
    end
  end


  def update_coach_entry
    proxy.update_entry(self.cybercoach_uri) do |entry|
      set_entry_values(entry)
    end

    date = merge_date(entry_date(false),entry_time(false))
    self.update_column(:date,date)
    self.invite(users_invited)
    ObjectStore::Store.remove([:coach_entry,self.id])
  end


  def merge_date(date, time)
    dt_date = DateTime.strptime(date, '%Y-%m-%d')
    dt_time = DateTime.strptime(time, '%H:%M')
    DateTime.new dt_date.year, dt_date.month, dt_date.day, dt_time.hour, dt_time.minute
  end


  def is_past
    self.date < Date.today
  end

  def is_upcoming
    self.date > Date.today
  end

  # Return the number of confirmed participants
  def n_participants
    self.sport_session_participants.where(:confirmed => true).count
  end

  def is_confirmed_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id, :confirmed => true).exists?
  end

  def is_unconfirmed_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id, :confirmed => false).exists?
  end

  def is_participant(user)
    self.sport_session_participants.where(:user_id =>  user.id).exists?
  end

  # Invite some users to join this event
  # @param user_ids Array of User-IDs
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


  # Factory method to return the result object for given user
  # @param user Rails user model
  #
  def result(user)
    participant = SportSessionParticipant.where(:user_id => user.id, :sport_session_id => self.id, :confirmed => true).first!

    case self.type
      when 'Running'
        result = RunningParticipantResult.where(:sport_session_participant_id => participant.id).first_or_create
      when 'Boxing'
        result = BoxingParticipantResult.where(:sport_session_participant_id => participant.id).first_or_create
      when 'Cycling'
        result = CyclingParticipantResult.where(:sport_session_participant_id => participant.id).first_or_create
      else
        raise 'Unknown Type'
    end

    result
  end


  # Return results of all users participated at this session
  #
  def get_all_results
    raise 'Must be implemented by subclass!'
  end


  # Return any achievement obtained by this event from the given user
  # @param user Rails user model
  #
  def achievements_obtained(user)
    user_achievements = UserAchievement.where(:sport_session_id => self.id, :user_id => user.id)
    achievements = user_achievements.map { |user_achievement| user_achievement.achievement }
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


  # find the given user's sport sessions based on filters (based on Stefan's CarTrading filter for offers)
  def self.all_sport_sessions_filtered_from_user(user_id, params, confirmed, type)
    if confirmed
      filtered_sessions = self.all_sport_sessions_confirmed_from_user(user_id, type)
    else
      filtered_sessions = self.all_sport_sessions_unconfirmed_from_user(user_id, type)
    end

    if params[:entry_location].present?
      filtered_sessions = filtered_sessions.where('location LIKE ?', "%#{params[:entry_location]}%")

    end

    if params[:date_to].present? && params[:date_from].present?
      date_from = DateTime.strptime(params[:date_from], Facade::SportSession::DATETIME_FORMAT)
      date_to = DateTime.strptime(params[:date_to], Facade::SportSession::DATETIME_FORMAT)+1
      date_range = {date: date_from..date_to}
      filtered_sessions = filtered_sessions.where(date_range)
    end

    if params[:participant].present?
      participant = {user_id: params[:participant]}
      filtered_sessions = filtered_sessions.joins(:sport_session_participants).where(sport_session_participants: participant)
    end

    filtered_sessions

  end

end
