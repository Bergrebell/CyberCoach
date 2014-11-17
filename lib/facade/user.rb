module Facade

  class User < Facade::BaseFacade


    # Creates a user for the rails application using the provided dependencies.
    # Returns a Facade::User user object.
    #
    # DO NOT USE THIS CONSTRUCTOR in the Rails App use Facade::User.create instead!
    #
    # ==== Attributes
    # The params hash accepts the following properties:
    #
    # * +cc_user+                     - cc_user of type RestAdapter::Models::User
    # * +auth_proxy+                  - auth_proxy of type RestAdapter::Proxy::BaseAuth
    # * +rails_user+                  - rails_user of type ::User
    #
    # ==== Example
    # Facade::User.create(username: 'alex', real_name: 'alex', email: 'test@test.com',
    #   password: 'test', password_confirmation: 'test')
    #   => Facade::User
    #
    def initialize(params={})
      @cc_user = params[:cc_user]
      @auth_proxy = params[:auth_proxy]
      @rails_user = params[:rails_user]
    end


    def self.rails_class
      ::User
    end


    def self.cc_class
      RestAdapter::Models::User
    end


    def id
      @rails_user.id
    end


    def auth_proxy
      @auth_proxy
    end


    def cc_model
      @cc_user
    end


    def rails_model
      @rails_user
    end


    # This class method creates a user for the rails application.
    # Returns a Facade::User user object.
    #
    # ==== Attributes
    # The params hash accepts the following properties:
    #
    # * +username+                    - username
    # * +real_name+                   - real name
    # * +password+                    - password
    # * +password_confirmation+       - password confirmation
    # * +email+                       - email
    #
    # ==== Example
    # Facade::User.create(username: 'alex', real_name: 'alex', email: 'test@test.com',
    #   password: 'test', password_confirmation: 'test')
    #   => Facade::User
    #
    def self.create(params={})
      params = params.merge(public_visible: RestAdapter::Privacy::Public) # always use public
      cc_user = RestAdapter::Models::User.new(params)
      auth_proxy = RestAdapter::Proxy::Auth.new username: cc_user.username, password: cc_user.password
      rails_user = ::User.new params.merge(username: params[:username], password: params[:password])
      self.new cc_user: cc_user, rails_user: rails_user, auth_proxy: auth_proxy
    end


    def authorized?
      @auth_proxy.authorized?
    end


    # Persists the created user.
    # Returns true if persisting the user succeeds otherwise false.
    #
    # ==== Example
    # user.save
    #
    def save
      return false if not @rails_user.save
      return false if not self.class.username_available?(@cc_user.username)
      return false if not @cc_user.save

      begin
        self.class.subscribe_user_to_all_subscriptions(@cc_user,@auth_proxy)
        true
      rescue
        @rails_user.destroy
        false
      end
    end


    # Updates a user object with the provided user attributes.
    # Returns a Facade::User user object or false if updating fails.
    #
    # ==== Attributes
    # The params hash accepts the following properties:
    #
    # * +username+                    - username
    # * +real_name+                   - real name
    # * +password+                    - password
    # * +password_confirmation+       - password confirmation
    # * +email+                       - email
    #
    # ==== Example
    # user.update(real_name: 'alex', email: 'test@test.com',
    #   password: 'test', password_confirmation: 'test')
    #   => Facade::User
    #
    def update(params={})
      @cc_user.fetch!
      user_hash = @cc_user.as_hash(:included_keys => [:password,:real_name,:username,:email]) # copy attributes
      new_user_hash = user_hash.merge(params) # merge copied user attributes with provided attributes.
      dummy_rails_user = ::User.new(new_user_hash.dup) # create a dummy rails user for validation purposes
      new_user_hash.delete(:username) # remove username attribute if available. changing the username is not permitted.
      @cc_user = RestAdapter::Models::User.new new_user_hash # create a new cc_user using the updated attributes.

      if @auth_proxy.authorized? and dummy_rails_user.valid? and @auth_proxy.save(@cc_user) # validation check
        @rails_user.assign_attributes(new_user_hash)
        @rails_user.save(validate: false)
        @auth_proxy = RestAdapter::Proxy::Auth.new username: @cc_user.username, password: @cc_user.password
        self
      else
        false
      end
    end


    # Deletes this user object.
    # Returns true if deleting this user succeeds otherwise false.
    #
    # ==== Example
    # user.delete
    #
    def delete
      return false if not @auth_proxy.authorized?

      begin
        # delete first all subscriptions, because cyber coach server, ehmm... does not behave well
        subscriptions = @cc_user.subscriptions
        subscriptions.each do |s|
          raise Error, 'Could not delete subscription!' if not @auth_proxy.delete(s)
        end

        partnerships = @cc_user.partnerships
        partnerships.each do |p|
          raise Error, 'Could not delete partnership!' if not @auth_proxy.delete(p)
        end

        raise Error, 'Could not delete cyber coach user!' if not @auth_proxy.delete(@cc_user)
        @rails_user.destroy
        true
      rescue
        false
      end
    end


    # clean up the object store when users logs out..
    def clean_up
      ObjectStore::Store.remove([@cc_user.username,:detailed_partnerships])
    end

    def partnerships
      @cc_user.partnerships.map { |p|  Facade::Partnership.new partnership: p, auth_proxy: @auth_proxy}
    end


    def friend_proposals(users)
      @cc_user.fetch! #update user and also its list of partnerships
      associated_partners = @cc_user.partnerships.map {|p| p.partner_of(@cc_user).username }
      users = users.select { |u| !associated_partners.include?(u.username) and u.username != @cc_user.username }
    end


    # Returns all friends of this user.
    def friends
      partnerships = cached_detailed_partnerships
      active_partnerships = partnerships.select { |p| p.active? } # filter, only get active partnerships
      active_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns all received friend requests of this user.
    def received_friend_requests
      partnerships = cached_detailed_partnerships
      proposed_partnerships = partnerships.select { |p| not p.confirmed_by?(@cc_user) } # filter, only get proposed partnerships
      proposed_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns all sent friend requests of this user.
    def sent_friend_requests
      partnerships = cached_detailed_partnerships
      proposed_partnerships = partnerships.select { |p| p.confirmed_by?(@cc_user) and not p.active? }
      proposed_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns true if this user is befriended with the given 'another_user'.
    def befriended_with?(another_user)
      not partnerships.select { |p|
        p.associated_with?(another_user)
      }.empty?
    end

    def not_befriended_with?(another_user)
      !befriended_with?(another_user)
    end

    def valid?
      @rails_user.valid?
    end


    # This class method authenticates a user against the rails application.
    # Returns a Facade::User user object if authentication succeeds otherwise false.
    #
    # If the user is not already registered in the local database it creates the missing user
    # and subscribes the user to all sport categories.
    #
    # ==== Attributes
    # The params hash accepts the following properties:
    #
    # * +username+        - username
    # * +password+        - password
    #
    # ==== Example
    # Facade::User.authenticate username: 'alex', password: 'test'
    #   => Facade::User
    #
    def self.authenticate(params) # here might be a higgs bugson
      if cc_user = RestAdapter::Models::User.authenticate(params)
        rails_user = if (check_user = ::User.find_by username: params[:username])
                       check_user
                     else # hack alert: if user does not exist in the database just create the user
                       new_user = ::User.new username: params[:username], password: params[:password]
                       new_user.save(:validate => false) #ignore rails model validation
                       new_user
                     end
        auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_user.id

        begin # if subscription fails...
          self.subscribe_user_to_all_subscriptions(cc_user, auth_proxy) # hack alert: always subscribe user to all sport subscriptions
          self.new cc_user: cc_user, rails_user: rails_user, auth_proxy: auth_proxy
        rescue
          false
        end
      else
        false
      end
    end


    def self.username_available?(username)
      RestAdapter::Models::User.username_available?(username)
    end


    def self.retrieve(params)
      user = RestAdapter::Models::User.retrieve params
      self.new cc_user: user, auth_proxy: RestAdapter::Proxy::InvalidAuth.new
    end


    def self.rails_wrap(rails_user)
      cc_user = RestAdapter::Models::User.new username: rails_user.username
      auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_user.id
      self.new rails_user: rails_user, cc_user: cc_user, auth_proxy: auth_proxy
    end


    def self.cc_wrap(cc_user)
      rails_user = ::User.find_by username: cc_user.username
      auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: rails_user.id
      self.new rails_user: rails_user, cc_user: cc_user, auth_proxy: auth_proxy
    end


    private

    def self.subscribe_user_to_all_subscriptions(cc_user,auth_proxy)
      RestAdapter::Models::Sport::Types.each do |sport|
        hash = {user: cc_user, sport: sport, public_visible: RestAdapter::Privacy::Public}
        subscription = RestAdapter::Models::Subscription.new(hash)
        raise Error, 'Could not create subscription!' if not auth_proxy.save(subscription)
      end
    end


    def cached_detailed_partnerships
      detailed_partnerships = ObjectStore::Store.get([@cc_user.username,:detailed_partnerships])
      if detailed_partnerships.nil?
        detailed_partnerships = @cc_user.fetch_partnerships
        ObjectStore::Store.set([@cc_user.username,:detailed_partnerships],detailed_partnerships)
      end
      detailed_partnerships
    end

  end

end