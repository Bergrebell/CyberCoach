module Facade

  class SportSession

    def initialize(params)
      @cc_entry = params[:cc_entry]
      @auth_proxy = params[:auth_proxy]
      @rails_sport_session = params[:rails_sport_session]
    end

    
    def self.create(params)
      # hidden dependencies
      auth_proxy = params[:cc_user].auth_proxy
      rails_user = ::User.find_by name: params[:cc_user].username
      rails_sport_session =  ::SportSession.new user_id: rails_user.id, type: params[:type]
      cc_subscription = RestAdapter::Models::Subscription.retrieve sport: params[:type], user: params[:cc_user]
      cc_type = RestAdapter::Models::Entry::TypeLookup[params[:type]]
      entry_hash = params.merge(subscription: cc_subscription, :public_visible => RestAdapter::Privacy::Public, type: cc_type)
      cc_entry = RestAdapter::Models::Entry.new entry_hash

      # inject dependencies
      self.new cc_entry: cc_entry, rails_sport_session: rails_sport_session, auth_proxy: auth_proxy
    end


    def save
      if entry_uri = @auth_proxy.save(@cc_entry)
        @rails_sport_session.cybercoach_uri = entry_uri
        @rails_sport_session.save
        true
      else
        false
      end
    end

    def update(params)

    end


    def delete

    end


    def self.method_missing(method, *args, &block)
      begin
        Models::Models::Entry.send method, *args, &block
      rescue
        ::SportSession.send method, *args, &block
      end
    end



    def method_missing(method, *args, &block)
      begin
        @cc_entry.send method, *args, &block
      rescue
        @rails_sport_session.send method, *args, &block
      end
    end


  end

end
