module Facade

  class SportSession

    def initialize(params)
      @cc_entry = params[:cc_entry]
      @rails_sport_session = params[:rails_sport_session]
    end

    
    def self.create(params)
      # hidden dependencies
      rails_user = ::User.find_by name: params[:cc_user].username
      rails_sport_session =  ::SportSession.new user_id: rails_user.id, type: params[:type]
      cc_subscription = RestAdapter::Models::Subscription.retrieve sport: params[:type], user: params[:cc_user]
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
        true
      else
        false
      end
    end

    def update(params)

    end


    def delete

    end




  end

end
