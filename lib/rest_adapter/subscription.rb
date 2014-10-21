module RestAdapter

  class Subscription < BaseResource
    # set subscription resource specific config values
    set_id self.get_prefix + '/' + :sport
    :partnership.nil? ? set_resource_path '/users' : set_resource_path '/partnerships'
    set_resource 'subscription'

    # getters and setters
    attr_accessor :sport, :user, :partnership, :entries

    #create a subscription
    def initialize(params = {})
      params = Hash[params.map {|k,v| [k.to_sym,v]}]
      @datesubscribed = params[:@datesubscribed]
      @id = params[:id]
      @uri = params[:uri]
      @publicvisible = params[:publicvisible]
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

    # open eigenclass
    class << self

      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash'
        end

        properties = {
            uri: params['uri'],
            id: params['id'],
            public_visible: params['publicvisible'],
            sport: params['sport'],
            user: params['user'],
            partnership: params['partnership']
        }

        if not params['user'].nil?
          module_name = Module.nesting.last  # workaround corresponds to the prefix RestAdapter
          user =  module_name::User.create(params['user'])
          properties = properties.merge({user: user})
        end

        if not params['partnership'].nil?
          module_name = Module.nesting.last  # workaround corresponds to the prefix RestAdapter
          partnership = module_name::Partnership.create(params['partnership'])
          properties = properties.merge({partnership: partnership})
        end

        if not params['sport'].nil?
          module_name = Module.nesting.last  # workaround corresponds to the prefix RestAdapter
          sport =  module_name::Sport.create(params['sport'])
          properties = properties.merge({sport: sport})
        end

        if not params['entries'].nil?
          module_name = Module.nesting.last  # workaround corresponds to the prefix RestAdapter
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
    end

  end
end