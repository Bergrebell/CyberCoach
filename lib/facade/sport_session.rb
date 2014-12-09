module Facade

  class SportSession < Facade::BaseFacade

    class Running < SportSession
      def self.create(params)
        super(params.merge(type: 'Running'))
      end

      def self.rails_class
        ::Running
      end
    end

    class Boxing < SportSession
      def self.create(params)
        super(params.merge(type: 'Boxing'))
      end

      def self.rails_class
        ::Boxing
      end
    end

    class Soccer < SportSession
      def self.create(params)
        super(params.merge(type: 'Soccer'))
      end

      def self.rails_class
        ::Soccer
      end
    end

    class Cycling < SportSession
      def self.create(params)
        super(params.merge(type: 'Cycling'))
      end

      def self.rails_class
        ::Cycling
      end
    end

    DATETIME_FORMAT = '%Y-%m-%d' # example: 2014-01-01
    # lookup tables for finding the right entry type and sport type

    EntryTypeLookup = {
        'Running' => RestAdapter::Models::Entry::Type::Running,
        'Boxing' => RestAdapter::Models::Entry::Type::Boxing,
        'Cycling' => RestAdapter::Models::Entry::Type::Cycling,
        'Soccer' => RestAdapter::Models::Entry::Type::Soccer,
        'running' => RestAdapter::Models::Entry::Type::Running,
        'boxing' => RestAdapter::Models::Entry::Type::Boxing,
        'cycling' => RestAdapter::Models::Entry::Type::Cycling,
        'soccer' => RestAdapter::Models::Entry::Type::Soccer
    }

    SportTypeLookup = {
          'Running' => RestAdapter::Models::Sport::Type::Running,
          'Boxing' => RestAdapter::Models::Sport::Type::Boxing,
          'Soccer' => RestAdapter::Models::Sport::Type::Soccer,
          'Cycling' => RestAdapter::Models::Sport::Type::Cycling,
          'running' => RestAdapter::Models::Sport::Type::Running,
          'boxing' => RestAdapter::Models::Sport::Type::Boxing,
          'soccer' => RestAdapter::Models::Sport::Type::Soccer,
          'cycling' => RestAdapter::Models::Sport::Type::Cycling
    }

    RailsModelClass = {
        'Running' => ::Running,
        'Boxing' => ::Boxing,
        'Soccer' => ::Soccer,
        'Cycling' => ::Cycling
    }

      def initialize(params={})
      # preconditions
      raise ':cc_entry is missing or wrong type!' if params[:cc_entry].nil? or not params[:cc_entry].is_a?(RestAdapter::Models::Entry)
      raise ':rails_sport_session is missing or wrong type!' if params[:rails_sport_session].nil? or not params[:rails_sport_session].is_a?(::SportSession)

      @cc_entry = params[:cc_entry]
      @rails_sport_session = params[:rails_sport_session]
      @auth_proxy =  params[:auth_proxy]
      @users_invited = params[:users_invited]
    end


    def self.rails_class
      ::SportSession
    end


    def self.cc_class
      RestAdapter::Models::Entry
    end


    def id
      @rails_sport_session.id
    end


    def cc_model
      @cc_entry
    end


    def rails_model
      @rails_sport_session
    end


    def auth_proxy
      @auth_proxy
    end


    def type
      @cc_entry.subscription.sport.name
    end


    # Correct entry_date string for the views.
    def date_created
      begin #Try if we can format entry date. If it fails then its probably nil.
        @cc_entry.date_created.strftime(DATETIME_FORMAT)
      rescue # if nil or another exception is raised just use an empty string
        ''
      end
    end

    def entry_date
      @rails_sport_session.entry_date
    end


    def self.create(params)
      # preconditions
      raise 'User is not of type Facade::User!' if params[:user].nil? or not params[:user].is_a?(Facade::User)
      raise 'Type is nil or empty string!' if params[:type].nil? or params[:type].empty?
      raise 'Facade::User has no cc_model. cc_model is nil!' if params[:user].cc_model.nil?
      raise 'Facade::User has no auth proxy. auth proxy is nil!' if params[:user].auth_proxy.nil?

      entry_date = DateTime.strptime(params[:entry_date] + params[:entry_time],'%Y-%m-%d %H:%M') rescue nil

      # hidden dependencies
      facade_user = params[:user]
      cc_user = facade_user.cc_model
      auth_proxy  = facade_user.auth_proxy
      rails_user = facade_user.rails_model
      rails_model_class = RailsModelClass[params[:type]]
      rails_sport_session =  rails_model_class.new
      rails_sport_session.assign_attributes(
          user_id: rails_user.id,
          type: params[:type],
          date: entry_date,
          entry_date: params[:entry_date],
          entry_time: params[:entry_time],
          location: params[:entry_location],
          title: params[:title],
          latitude: params[:latitude],
          longitude: params[:longitude]
      )

      # Array of IDs of users that we want to invite for the sport session
      users_invited = (params[:users_invited].present? and params[:users_invited].kind_of?(Array)) ? params[:users_invited] : []

      # create pseudo subscription
      cc_type = Facade::SportSession::EntryTypeLookup[params[:type]]
      cc_sport = Facade::SportSession::SportTypeLookup[params[:type]]
      cc_subscription = RestAdapter::Models::Subscription.new sport: cc_sport, user: cc_user
      cc_visible = RestAdapter::Privacy::Public

      # create entry
      entry_hash = params.merge(subscription: cc_subscription, public_visible: cc_visible, type: cc_type, entry_date: entry_date)
      cc_entry = RestAdapter::Models::Entry.new entry_hash

      # inject dependencies
      self.new cc_entry: cc_entry, rails_sport_session: rails_sport_session, auth_proxy: auth_proxy, users_invited: users_invited
    end


    def save(params={})
      begin


        if @rails_sport_session.save && entry_uri = @auth_proxy.save(@cc_entry)
          raise 'Error' if entry_uri.nil? || entry_uri.empty?
          @rails_sport_session.cybercoach_uri = entry_uri
          @rails_sport_session.save

          @rails_sport_session.invite(@users_invited)

          # The user creating the entry also needs a SportSessionParticipant object
          SportSessionParticipant.where(
              :user_id => @rails_sport_session.user_id,
              :sport_session_id => @rails_sport_session.id,
              :confirmed => true
          ).first_or_create

          entry_uri
        else
          false
        end
      rescue
        false
      end
    end


    def update(params={})
      type = Facade::SportSession::EntryTypeLookup[@rails_sport_session.type]
      entry_hash = params.dup.merge(type: type)
      entry_date = DateTime.strptime(params[:entry_date] + params[:entry_time],'%Y-%m-%d %H:%M') rescue nil
      begin
        # sync rails sport session properties
        rails_sport_session_properties = {
            location: entry_hash[:entry_location],
            date: entry_date,
            entry_date: params[:entry_date],
            entry_time: params[:entry_time],
            title: entry_hash[:title],
            latitude: params[:latitude],
            longitude: params[:longitude]
        }

        @rails_sport_session.assign_attributes rails_sport_session_properties

        # Also update invited friends
        users_invited = (entry_hash[:users_invited].present? and entry_hash[:users_invited].kind_of?(Array)) ? entry_hash[:users_invited] : []
        @rails_sport_session.invite(users_invited)

        entry_hash = entry_hash.merge(uri: @rails_sport_session.cybercoach_uri, cc_id: @cc_entry.cc_id)
        @cc_entry = RestAdapter::Models::Entry.new entry_hash
        @rails_sport_session.save && @auth_proxy.save(@cc_entry)
      rescue
        false
      end
    end


    def delete
      @rails_sport_session.destroy
      @auth_proxy.delete(@cc_entry) # if it fails i don't care....
      true
    end


    def errors
      @rails_sport_session.errors
    end


    def self.rails_wrap(rails_sport_session)
      begin
        cc_entry = RestAdapter::Models::Entry.retrieve rails_sport_session.cybercoach_uri
        auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_sport_session.user_id
        self.new rails_sport_session: rails_sport_session, cc_entry: cc_entry, auth_proxy: auth_proxy
      rescue
        nil
      end
    end


    def self.cc_wrap(cc_entry)
      begin
        rails_sport_session = ::SportSession.find_by cybercoach_uri: cc_entry.uri
        auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_sport_session.user_id
        self.new rails_sport_session: rails_sport_session, cc_entry: cc_entry, auth_proxy: auth_proxy
      rescue
        nil
      end
    end


  end

end
