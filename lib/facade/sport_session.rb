module Facade

  class SportSession < Facade::BaseFacade

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
          'Running' => RestAdapter::Models::Sport.new(name: 'Running'),
          'Boxing' => RestAdapter::Models::Sport.new(name: 'Boxing'),
          'Soccer' => RestAdapter::Models::Sport.new(name: 'Soccer'),
          'Cycling' => RestAdapter::Models::Sport.new(name: 'Cycling'),
          'running' => RestAdapter::Models::Sport.new(name: 'Running'),
          'boxing' => RestAdapter::Models::Sport.new(name: 'Boxing'),
          'soccer' => RestAdapter::Models::Sport.new(name: 'Soccer'),
          'cycling' => RestAdapter::Models::Sport.new(name: 'Cycling'),
    }


    def initialize(params={})
      # preconditions
      raise Error, ':cc_entry is missing or wrong type!' if params[:cc_entry].nil? or not params[:cc_entry].is_a?(RestAdapter::Models::Entry)
      raise Error, ':rails_sport_session is missing or wrong type!' if params[:rails_sport_session].nil? or not params[:rails_sport_session].is_a?(::SportSession)

      @cc_entry = params[:cc_entry]
      @rails_sport_session = params[:rails_sport_session]
      @auth_proxy =  params[:auth_proxy]
    end

    def self.facade_for_2
      ::SportSession
    end

    def self.facade_for_1
      nil
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

    
    def self.create(params)
      # preconditions
      raise Error, 'User is not of type Facade::User!' if params[:user].nil? or not params[:user].is_a?(Facade::User)
      raise Error, 'Type is nil or empty string!' if params[:type].nil? or params[:type].empty?
      raise Error, 'Facade::User has no cc_model. cc_model is nil!' if params[:user].cc_model.nil?
      raise Error, 'Facade::User has no auth proxy. auth proxy is nil!' if params[:user].auth_proxy.nil?

      # hidden dependencies
      facade_user = params[:user]
      cc_user = facade_user.cc_model
      auth_proxy  = facade_user.auth_proxy
      rails_user = facade_user.rails_model
      rails_sport_session =  ::SportSession.new user_id: rails_user.id, type: params[:type]

      # create pseudo subscription
      cc_type = Facade::SportSession::EntryTypeLookup[params[:type]]
      cc_sport = Facade::SportSession::SportTypeLookup[params[:type]]
      cc_subscription = RestAdapter::Models::Subscription.new sport: cc_sport, user: cc_user
      cc_visible = RestAdapter::Privacy::Public

      # create entry
      entry_hash = params.merge(subscription: cc_subscription, public_visible: cc_visible, type: cc_type)
      cc_entry = RestAdapter::Models::Entry.new entry_hash

      # inject dependencies
      self.new cc_entry: cc_entry, rails_sport_session: rails_sport_session, auth_proxy: auth_proxy
    end


    def save(params={})
      begin
        if entry_uri = @auth_proxy.save(@cc_entry)
          raise Error if entry_uri.nil? or entry_uri.empty? or entry_uri.size==1 # hack alert: is this a higgs bugson???
          @rails_sport_session.cybercoach_uri = entry_uri
          @rails_sport_session.save
          entry_uri
        else
          false
        end
      rescue
        false
      end
    end

    def update(params={})
      update_attributes(params)
      @auth_proxy.save(@cc_entry)
    end


    def update_attributes(params)
      entry_hash = params.dup
      entry_hash[:type] = Facade::SportSession::EntryTypeLookup[params[:type]]
      begin
        entry_hash = entry_hash.merge(uri: @rails_sport_session.cybercoach_uri, cc_id: @cc_entry.cc_id)
        @cc_entry = RestAdapter::Models::Entry.new entry_hash
      rescue => e
        # do nothing
        raise e
      end
    end


    def delete
      @auth_proxy.delete(@cc_entry)
    end


    def errors
      @rails_sport_session.errors
    end


    def self.wrap(rails_sport_session)
      cc_entry = RestAdapter::Models::Entry.retrieve rails_sport_session.cybercoach_uri
      auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_sport_session.user_id
      self.new rails_sport_session: rails_sport_session, cc_entry: cc_entry, auth_proxy: auth_proxy
    end

  end

end
