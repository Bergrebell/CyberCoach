module RestAdapter

  # Subscription implements an adapter for the resource Subscription
  # from the Cyber Coach Server.

  # It provides simple interface for retrieving, saving, updating
  # and deleting Subscriptions.
  #
  class Subscription < BaseResource
    # set subscription resource specific config values

    # getters and setters
    attr_accessor :sport, :user, :partnership, :public_visible, :date_subscribed

    set_resource 'subscription'
    set_resource_path users: '/users', partnerships: '/partnerships'

    serialize_properties :public_visible
    deserialize_properties :id, :uri, :partnership, :entries, :user, :public_visible, :date_subscribed, :date_created, :sport

    after_deserialize do |params|
      properties = Hash.new
      properties.update({user: module_name::User.create(params['user'])}) if not params['user'].nil?
      properties.update({partnership: module_name::Partnership.create(params['partnership'])}) if not params['partnership'].nil?
      properties.update({sport: module_name::Sport.create(params['sport'])}) if not params['sport'].nil?
      properties.update({entries: params['entries'].map { |p| module_name::Entry.create p }}) if not params['entries'].nil?
    end

    # open eigenclass to override class methods from the base resource class.
    class << self

      # This class method overrides 'create_entity_uri' form the base resource class.
      # It creates a subscription entity uri.
      #
      # ==== Attributes
      # The params hash accepts the following properties:
      #
      # * +path+
      # * +id+
      #
      # ==== Examples
      # create_entity_uri(path: :users, id: 'alex/Running') => 'base/site/users/alex/Running'
      # create_entity_uri(path: :partnerships, id: 'alex;timon/Running') => 'base/site/users/alex;timon/Running'
      #
      def create_absolute_resource_uri(params)
        path_key = params[:path]
        id = params[:id]
        base + site +  resource_path[path_key] + '/' + id
      end


      # This class method overrides 'retrieve' from the base resource class.
      # Returns a subscription given a partnership, a user and a sport category.
      #
      # ==== Attributes
      # The params hash accepts the following properties:
      #
      # * +partnership+   - a partnership object or a string that fully specifies a partnership
      # * +user+          - a user object or a username
      # * +first_user+    - a user object or a username
      # * +second_user+   - a user object or a username
      # * +sport+         - a string that specifies a sport category
      #
      # ==== Examples
      # Subscription.retrieve(partnership: a partnership object, sport: 'Running') => Subscription
      # Subscription.retrieve(partnership: 'alex;timon', sport: 'Running') => Subscription
      # Subscription.retrieve(user: 'alex', sport: 'Running') => Subscription
      # Subscription.retrieve(first_user: 'alex', second_user: 'timon', sport: 'Running') => Subscription
      #
      def retrieve(params)
        # preprocesses the provided params and creates a hash which looks like this:
        # {id: some id, path: some path }
        id = parse_params(params)
        super(id)
      end

    end

    # This method overrides 'id' from the base resource class.
    def id
      if not defined? @id or @id.nil?
        part = !user.nil? ? user.username : partnership.id
        "#{part}/#{sport}"
      else
        @id
      end
    end

    # This method overrides 'uri' from the base resource class.
    def uri
      if not defined? @uri or @uri.nil?
        key = !user.nil? ? :users : :partnerships
        self.class.site + self.class.resource_path[key] + '/' + self.id
      else
        @uri
      end
    end


    def create_absolute_uri
      path_key = !user.nil? ? :users : :partnerships
      self.class.base + self.class.site +  self.class.resource_path[path_key] + '/' + id
    end


    # This method returns a collection of entries.
    def entries
      entries = self.entries.map {|p| p.fetch }
    end


    # open eigenclass to define class specific class methods
    class << self

      private


      # This class method parses a hash called params.
      # It returns a hash that looks as follows { id: some id, path: :users or :partnerships }.
      #
      # ==== Attributes
      # The params hash accepts the following properties:
      #
      # * +partnership+   - a partnership object or a string that fully specifies a partnership
      # * +user+          - a user object or a username
      # * +first_user+    - a user object or a username
      # * +second_user+   - a user object or a username
      # * +sport+         - a string that specifies a sport category
      #
      # ==== Examples
      # parse_params(user: 'alex', sport: 'Running')
      #     => {path: :users, id: 'alex/Running'}
      #
      # parse_params(partnership: 'alex;timon', sport: 'Running')
      #     => {path: :partnerships, id: 'alex;timon/Running'}
      #
      # parse_params(first_user: 'alex' second_user ;'timon', sport: 'Running')
      #     => {path: :partnerships, id: 'alex;timon/Running'}
      #
      def parse_params(params)
        #TODO: replace all kind_of? calls with is_a? calls. Why? Because it's more concise and it sounds better.
        if params.is_a?(Hash) # check if params is a hash, parse params

          #check sport category
          raise ArgumentError, 'Argument sport is missing.' if params[:sport].nil?
          sport = params[:sport]

          # 1) support retrieval over partnerships
          # get a id, path tuple
          tuple = if not params[:partnership].nil?
            # support both partnership param as valid user1;user2 string or as partnership object
            partnership = params[:partnership].is_a?(String) ? params[:partnership] : params[:partnership].id

            [partnership, :partnerships] # return this as tuple

          # 2) support retrieval over first user and second user
          elsif not params[:first_user].nil? and not params[:second_user].nil?
            # support both usernames and users
            first_user = params[:first_user].is_a?(String) ? params[:first_user] : params[:first_user].username
            second_user = params[:second_user].is_a?(String) ? params[:second_user] : params[:second_user].username

            [ "#{first_user};#{second_user}", :partnerships ] # return this as tuple

          # 3) support retrieval over a single user
          elsif not params[:user].nil?
            # support both usernames and users
            user = params[:user].is_a?(String) ? params[:user] : params[:user].username

            [user, :users] # return this as tuple

          else # otherwise raise an error
            raise ArgumentError, 'Argument partnership / first_user / second_user is missing.'
          end

          id, path = tuple
          { id: "#{id}/#{sport}", path:  path }

        else # otherwise assume it's a string.
          { id: params, path: nil }
        end
      end

    end

  end
end
