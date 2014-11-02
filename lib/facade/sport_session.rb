module Facade

  class SportSession

    def initialize(params={})
      @cc_entry = params[:cc_entry]
      @rails_sport_session = params[:rails_sport_session]
    end

    
    def self.create(params)
      raise Error if params[:facade_user].nil?
      raise Error if params[:type].nil?
      # hidden dependencies
      cc_user = params[:facade_user].cc_user
      rails_user = ::User.find_by name: params[:facade_user].username
      rails_sport_session =  ::SportSession.new user_id: rails_user.id, type: params[:type]
      cc_subscription = RestAdapter::Models::Subscription.retrieve sport: params[:type], user: cc_user
      cc_type = RestAdapter::Models::Entry::TypeLookup[params[:type]]
      entry_hash = params.merge(subscription: cc_subscription, :public_visible => RestAdapter::Privacy::Public, type: cc_type)
      cc_entry = RestAdapter::Models::Entry.new entry_hash

      # inject dependencies
      self.new cc_entry: cc_entry, rails_sport_session: rails_sport_session
    end


    def save(params={})
      if entry_uri = @cc_entry.save(params)
        @rails_sport_session.cybercoach_uri = entry_uri
        @rails_sport_session.save
        entry_uri
      else
        false
      end
    end

    def update(params)

    end


    def delete

    end


    def self.wrap(sport_session)
      cc_entry = RestAdapter::Models::Entry.retrieve sport_session.cybercoach_uri
      self.new rails_sport_session: sport_session, cc_entry: cc_entry
    end


    def id
      @rails_sport_session.id
    end

    def cc_id
      @cc_entry.id
    end

    def method_missing(method, *args, &block)
      begin
        @cc_entry.send method, *args, &block
      rescue
        @rails_sport_session.send method, *args, &block
      end
    end


    # map where, find etc from rails....good luck...it might bite you!!!!!
    def self.method_missing(method, *args, &block)
      result = ::SportSession.send method, *args, &block
      case result
        when ::ActiveRecord::Relation
          result.to_a.map {|r| wrap(r) }
        else
          wrap(result)
      end
    end



  end

end
