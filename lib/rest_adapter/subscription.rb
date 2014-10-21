module RestAdapter

  class Subscription < BaseResource
    # set subscription resource specific config values
    set_id :id

    # getters and setters
    attr_accessor :sport, :user, :partnership, :entries, :public_visible, :date_subscribed

    set_resource 'subscription'
    set_resource_path users: '/users', partnerships: '/partnerships' # Hack alert!

    # open eigenclass to override class methods from the base resource class.
    class << self

      # Hack alert!
      # Overrides 'create_entity_uri'.
      # It takes a hash which looks like this: {id: some id, path: :users or :partnerships }.
      def create_entity_uri(params)
        path_key = params[:path]
        id = params[:id]
        base + site +  resource_path[path_key] + '/' + id
      end

      # Overrides 'retrieve'
      #
      def retrieve(params)
        # preprocess the provided params and creates a hash which looks like this:
        # {id: some id, path: some path }
        id = parse_params(params)
        super(id)
      end

    end


    #create a subscription
    def initialize(params = {})
      params = Hash[params.map {|k,v| [k.to_sym,v]}]
      @date_subscribed = params[:datesubscribed]
      @id = params[:id]
      @uri = params[:uri]
      @public_visible = params[:publicvisible]
      @sport = params[:sport]
      @user = params[:user]
      @partnership = params[:partnership]
      @entries = params[:entries]
    end

    # extract the prefix needed to set an id;
    # {username1};{username2} for partnership subscriptions;
    # {username} for user subscriptions
    def get_prefix
      uri = self.uri
      prefix = uri.split('/')[uri.length-2] # get the last but one segment in the uri path
      prefix = prefix[0...-1] if prefix[-1] == '/' # remove last forward slash if present
      return prefix
    end


    #returns all entries in this subscription
    def entries
      entries = self.entries.map {|p| p.fetch }
    end


    # open eigenclass to define class specific class methods
    class << self

      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash.'
        end

        properties = {
            uri: params['uri'],
            id: params['id'],
            public_visible: params['publicvisible']
        }

        if not params['user'].nil?
          user =  module_name::User.create(params['user'])
          properties = properties.merge({user: user})
        end

        if not params['partnership'].nil?
          partnership = module_name::Partnership.create(params['partnership'])
          properties = properties.merge({partnership: partnership})
        end

        if not params['sport'].nil?
          sport =  module_name::Sport.create(params['sport'])
          properties = properties.merge({sport: sport})
        end

        if not params['entries'].nil?
          entries =  params['entries'].map {|p| module_name::Entry.create p }
          properties = properties.merge({entries: entries})
        end

        new(properties)
      end


      def serialize(subscription)
        if not subscription.kind_of?(Subscription)
          raise ArgumentError, 'Argument must be of type subscription'
        end
        hash = {
            publicvisible: subscription.public_visible
        }
        hash.to_xml(root: 'subscription')
      end

      private

      # Extreme hack alert!
      # Parses the passed params hash and creates a valid subscription id based on the properties
      # :user, :partnership, :sport, :second_user, :first_user
      #
      # It returns a hash which looks like this:
      # { id: some id, path: :users or :partnerships}
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