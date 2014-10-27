module RestAdapter

  module Models

    module RetrievableWithParams

      module Partnership

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods


          # This class method overrides 'retrieve'.
          # Returns a subscription given a partnership, a user and a sport category.
          #
          # ==== Attributes
          # The params hash accepts the following properties:
          #
          # * +string+        - a string
          # * +first_user+    - a user object or a username
          # * +second_user+   - a user object or a username
          #
          # ==== Examples
          # Partnership.retrieve('alex;timon', sport: 'Running') => Partnership
          # Partnership.retrieve(first_user: 'alex', second_user: 'timon') => Partnership
          #
          def retrieve(params)
            id = parse_params(params)
            super(id)
          end

          def parse_params(params)
            if params.is_a?(Hash) # check if hash
              raise ArgumentError, 'Argument first_user / second user is missing.' if params[:first_user].nil? or params[:second_user].nil?
              # support both usernames and users
              first_user = params[:first_user].is_a?(String) ? params[:first_user] : params[:first_user].username
              second_user = params[:second_user].is_a?(String) ? params[:second_user] : params[:second_user].username
              "#{first_user};#{second_user}"
            else # otherwise assume it's a string
              params
            end
          end

        end

      end


      module Subscription

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          # This class method overrides 'create_entity_uri' from the base resource class.
          # It creates a subscription entity uri.
          #
          # ==== Attributes
          # The params hash accepts the following properties:
          #
          # * +path+
          # * +id+
          #
          # ==== Examples
          # create_absolute_resource_uri(path: :users, uri: 'alex/Running') => 'base/site/users/alex/Running'
          # create_absolute_resource_uri(path: :users, uri: 'alex/Running/10') => 'base/site/users/alex/Running/10'
          # create_absolute_resource_uri(path: :partnerships, id: 'alex;timon/Running') => 'base/site/users/alex;timon/Running'
          #
          def create_absolute_resource_uri(params)
            path_key = params[:path] # can be nil, :users, :partnerships
            path = path_key.nil? ? '' : resource_path[path_key]
            uri = params[:uri]
            base + site +  path + '/' + uri
          end


          # This class method overrides 'retrieve'.
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
            # {uri: some id, path: some path }
            uri = parse_params(params)
            super(uri)
          end


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
          #     => {path: :users, uri: 'alex/Running'}
          #
          # parse_params(partnership: 'alex;timon', sport: 'Running')
          #     => {path: :partnerships, uri: 'alex;timon/Running'}
          #
          # parse_params(first_user: 'alex' second_user ;'timon', sport: 'Running')
          #     => {path: :partnerships, uri: 'alex;timon/Running'}
          #
          # parse_params(first_user: 'alex' second_user ;'timon', sport: 'Running', id: 10)
          #     => {path: :partnerships, uri: 'alex;timon/Running/10'}
          #
          def parse_params(params)
            #TODO: replace all kind_of? calls with is_a? calls. Why? Because it's more concise and it sounds better.
            if params.is_a?(Hash) # check if params is a hash, parse params

              # check sport category
              raise ArgumentError, 'Argument sport is missing.' if params[:sport].nil?
              sport = params[:sport]
              # check if id params is available
              id = params[:id].nil? ? '' :  params[:id]

              # 1) support retrieval over partnerships
              # get a (uri, path) tuple
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

              uri, path = tuple
              { uri: "#{uri}/#{sport}/#{id}", path:  path }

            else # otherwise assume it's a string.
              { uri: params, path: nil }
            end
          end

        end

      end

    end

  end

end