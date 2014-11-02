module Facade

  class User < Facade::BaseFacade

    # instance methods

    attr_accessor :cc_user, :rails_user, :auth_proxy

    def initialize(params={})
      @cc_user = params[:cc_user]
      @auth_proxy = params[:auth_proxy]
      @rails_user = params[:rails_user]
    end


    # factory method
    def self.create(params={})
      params = params.merge(public_visible: RestAdapter::Privacy::Public) # always use public
      cc_user = RestAdapter::Models::User.new(params)
      auth_proxy = RestAdapter::Proxy::Auth.new username: cc_user.username, password: cc_user.password
      rails_user = ::User.new params.merge(name: params[:username]) # please change the rails model!!!
      self.new cc_user: cc_user, rails_user: rails_user, auth_proxy: auth_proxy
    end

    # factory method
    def self.wrap(params={})
      cc_user = RestAdapter::Models::User.authenticate(params)
      auth_proxy = RestAdapter::Proxy::Auth.new username: cc_user.username, password: cc_user.password
      rails_user = ::User.find_by name: cc_user.username
      self.new cc_user: cc_user, rails_user: rails_user, auth_proxy: auth_proxy
    end


    def authorized?
      @auth_proxy.authorized?
    end


    def save
      return false if not @rails_user.save
      return false if not self.class.username_available?(@cc_user.username)
      return false if not @cc_user.save

      begin
        RestAdapter::Models::Sport::Types.each do |sport|
          hash = {user: @cc_user, sport: sport, public_visible: RestAdapter::Privacy::Public}
          subscription = RestAdapter::Models::Subscription.new(hash)
          raise Error, 'Could not create subscription!' if not @auth_proxy.save(subscription)
        end
        true
      rescue
        @rails_user.delete
        false
      end
    end


    def update(params=nil)
      if not params.nil?
        @cc_user = RestAdapter::Models::User.new params
        @rails_user = ::User.new params
      end

      if @auth_proxy.authorized? and @rails_user.valid? and @auth_proxy.save(@cc_user)
        @auth_proxy = RestAdapter::Proxy::Auth.new username: @cc_user.username, password: @cc_user.password
      end
    end


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

    def id
      @rails_user.id
    end

    def friend_proposals(users)
      @cc_user.fetch! #update user and also its list of partnerships
      associated_partners = @cc_user.partnerships.map {|p| p.partner_of(@cc_user).username }
      users = users.select { |u| !associated_partners.include?(u.username) and u.username != @cc_user.username }
    end


    def cached_detailed_partnerships
      detailed_partnerships = ObjectStore::Store.get([@cc_user.username,:detailed_partnerships])
      if detailed_partnerships.nil?
        detailed_partnerships = @cc_user.fetch_partnerships
        ObjectStore::Store.set([@cc_user.username,:detailed_partnerships],detailed_partnerships)
      end
      detailed_partnerships
    end


    # Returns all friends of this user.
    def friends
      partnerships = self.cached_detailed_partnerships
      active_partnerships = partnerships.select { |p| p.active? } # filter, only get active partnerships
      active_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns all received friend requests of this user.
    def received_friend_requests
      partnerships = self.cached_detailed_partnerships
      proposed_partnerships = partnerships.select { |p| not p.confirmed_by?(@cc_user) } # filter, only get proposed partnerships
      proposed_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns all sent friend requests of this user.
    def sent_friend_requests
      partnerships = self.cached_detailed_partnerships
      proposed_partnerships = partnerships.select { |p| p.confirmed_by?(@cc_user) and not p.active? }
      proposed_partnerships.map { |p| p.partner_of(@cc_user) } # get users instead of partnerships
    end


    # Returns true if this user is befriended with the given 'another_user'.
    def befriended_with?(another_user)
      not self.cached_detailed_partnerships.select { |p|
        p.associated_with?(another_user)
      }.empty?
    end

    def not_befriended_with?(another_user)
      !befriended_with?(another_user)
    end

    def valid?
      @rails_user.valid?
    end


    def method_missing(method, *args, &block)
      begin
        @cc_user.send method, *args, &block
      rescue
        @rails_user.send method, *args, &block
      end
    end

    # class methods

    def self.authenticate(params)
      if cc_user = RestAdapter::Models::User.authenticate(params)
        auth_proxy = RestAdapter::Proxy::Auth.new username: cc_user.username, password: cc_user.password, subject: cc_user
        rails_user = if (check_user = ::User.find_by name: cc_user.username)
                       check_user
                     else
                       new_user = ::User.new name: cc_user.username
                       new_user.save(:validate => false)
                       new_user
                      end

        facade_user = self.new cc_user: cc_user, rails_user: rails_user, auth_proxy: auth_proxy
      else
        false
      end
    end


    def self.username_available?(username)
      RestAdapter::Models::User.username_available?(username)
    end





    def self.method_missing(method, *args, &block)
      begin
        RestAdapter::Models::User.send method, *args, &block
      rescue
        ::User.send method, *args, &block
      end
    end

  end

end