module RestAdapter

  module Models

    # Subscription implements an adapter for the resource Subscription
    # from the Cyber Coach Server.

    # It provides simple interface for retrieving, saving, updating
    # and deleting Subscriptions.
    #
    class Subscription < BaseResource
      include RestAdapter::Behaviours::DependencyInjector
      include RestAdapter::Behaviours::LazyLoading
      # set subscription resource specific config values

      # getters and setters
      attr_accessor :cc_id, :sport, :user, :partnership, :public_visible, :date_subscribed, :entries

      set_resource 'subscription'
      set_resource_path users: '/users', partnerships: '/partnerships'

      serialize_properties :public_visible
      deserialize_properties  :uri, :partnership, :entries, :user, :public_visible, :date_subscribed,
                              :date_created, :sport, :id => :cc_id

      inject :user => RestAdapter::Models::User, :partnership => Partnership,
             :sport => RestAdapter::Models::Sport, :entries => RestAdapter::Models::Entry

      lazy_loading_on :user, :sport, :partnership, :public_visible, :entries

      after_deserialize do |params|
        if not params['uri'].nil? and params['user'].nil? and params['sport'].nil?
          uri = params['uri'][-1] == '/' ? params['uri'][0...-1] : params['uri']
          *, username, sport = uri.split('/')
          {user: ({'username' => username}),
           sport: ({'name' => sport})}
        end
      end


      class << self
        # This class method overrides 'retrieve'.
        # Returns a subscription given a partnership, a user and a sport category.
        #
        # ==== Attributes
        # The params hash accepts the following properties:
        #
        # * +partnership+   - a partnership object
        # * +user+          - a user object
        # * +sport+         - a string that specifies a sport category
        # * +options+       - an optional hash for options
        #
        # ==== Examples
        # Subscription.retrieve(partnership: a partnership object, sport: 'Running') => Subscription
        # Subscription.retrieve(user: a user object, sport: 'Running') => Subscription
        # Subscription.retrieve('/users/newuser4/Running') => Subscription
        # Subscription.retrieve('/users/newuser4/Running', {authorization: 'Basic Bksdjfkjskldfj='} ) => Subscription
        # Subscription.retrieve({user: a user object, sport: 'Running'}, {authorization: 'Basic Bksdjfkjskldfj='} ) => Subscription
        #
        def retrieve(params, options={})
          resource_path_id = parse_retrieve_params(params)
          super(resource_path_id, options)
        end

      end


      # This method returns a collection of entries.
      def entries
        entries = self.entries.map { |p| p.fetch }
      end

      module ClassMethods

        # This class method overrides 'create_absolute_resource_uri' from the base resource class.
        def create_absolute_resource_uri(resource_path_id)
          base + site + resource_path_id
        end

        def parse_retrieve_params(params)
          if params.is_a?(Hash) # check if hash
            raise Error, ':sport key is missing' if params[:sport].nil?
            sport = params[:sport].is_a?(String) ? params[:sport] : params[:sport].id
            path_key, user_partnership_id = if not params[:partnership].nil?
                                              partnership_id = if params[:partnership].is_a?(String)
                                                                 params[:partnership]
                                                               else
                                                                 params[:partnership].id
                                                               end
                                              [:partnerships, partnership_id]
                                            elsif not params[:user].nil?
                                              user_id = if params[:user].is_a?(String)
                                                          params[:user]
                                                        else
                                                          params[:user].id
                                                        end
                                              [:users, user_id]
                                            end
            user_partnership_path = resource_path[path_key] # get the right path that is associated with the path key
            "#{user_partnership_path}/#{user_partnership_id}/#{sport}"
          else #otherwise assume its a string
            params
          end
        end

      end

      module InstanceMethods

        # This method overrides 'id' from the base resource class.
        def id
          if @id.nil? #if id is not available try to build one using the properties
            # find out if the subscription is associated with a user or a partnership
            user_partnership_id = !user.nil? ? user.id : partnership.id
            "#{user_partnership_id}/#{sport.id}"
          else
            @id
          end
        end


        # This method overrides 'uri' from the base resource class.
        def uri
          if @uri.nil? #if uri is not available try to build one using the properties
            self.class.site + self.resource_path + '/' + self.id
          else
            @uri
          end
        end


        # This method overrides 'create_absolute_uri' from the base resource class.
        def create_absolute_uri
          self.class.base + self.class.site + self.resource_path + '/' + id
        end


        def resource_path
          resource_path_key = !user.nil? ? :users : :partnerships
          self.class.resource_path[resource_path_key]
        end


      end



      extend ClassMethods
      include InstanceMethods
    end
  end
end