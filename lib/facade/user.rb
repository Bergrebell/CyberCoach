module Facade

  class User

    def initialize(params)
      @subject = RestAdapter::Models::User.new(params)
    end


    def save
      if @subject.save
        auth_proxy = RestAdapter::AuthProxy.new user: @subject
        RestAdapter::Models::Sport::Type.constants.each do |constant|

          sport = RestAdapter::Models::Sport::Type.const_get constants
          hash = { user: @subject, sport: sport, public_visible: RestAdapter::Privacy::Public }
          subscription = RestAdapter::Models::Subscription.new(hash)
          ok = auth_proxy.save(subscription)

          return false if !ok
        end
      else
        false
      end
    end


    def self.method_missing(method, *args, &block)
      RestAdapter::Models::User.send method, *args, &block
    end


    def method_missing(method, *args, &block)
      @subject.send method, *args, &block
    end

  end

end