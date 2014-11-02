module RestAdapter

  module Behaviours

    module Crudable

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods, HelperClassMethods

        # Required class methods (preconditions) which must be implemented for using this behaviour.
        raise 'ActiveRecord#deserialize() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize
        raise 'ActiveRecord#serialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.serialize_format
        raise 'ActiveRecord#deserialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize_format
      end

      # module helper class methods

      module HelperClassMethods
        def parse_query_options(options)
          # if query is not set, use default
          query_options = options[:query].nil? ? {start: 0, size: 999} : options[:query]
          # build query
          uri = Addressable::URI.new
          uri.query_values = query_options
          q = '?' + uri.query
        end


        def get_basic_options
          {content_type: self.serialize_format,
           accept: self.deserialize_format}
        end


        def get_default_response_handler
          proc do |response, request, result|
            self.deserialize(response)
          end
        end

        def clear_options(hash)
          options = hash.dup
          options.delete(:method)
          options.delete(:response_handler)
          options.delete(:query)
          options
        end

      end



      module InstanceMethods

        # Fetches all details for this resource object and returns a object
        # containing all details.
        #
        def fetch(params={})
          options = params.dup
          q = self.class.parse_query_options(options)
          uri = self.absolute_uri + q

          basic_options = self.class.get_basic_options
          cleared_options = self.class.clear_options(options)
          http_options = basic_options.merge(cleared_options)

          begin
            response = RestClient.get(uri, http_options)
            # get deserializer
            self.class.deserialize(response)
          rescue Exception => e
            puts e
            raise e if options[:raise]
            false
          end
        end


        # Fetches all detail information of this resource object and modifies its internal properties
        # according the fetched details.
        #
        def fetch!(params={})
          options = params.dup
          q = self.class.parse_query_options(options)
          uri = self.absolute_uri + q

          basic_options = self.class.get_basic_options
          cleared_options = self.class.clear_options(options)
          http_options = basic_options.merge(cleared_options)

          begin
            response = RestClient.get(uri, http_options)
            obj = self.class.deserialize(response)
            variables = obj.instance_variables
            variables.each do |variable|
              self.instance_variable_set(variable, obj.instance_variable_get(variable))
            end
            obj
          rescue Exception => e
            puts e
            raise e if options[:raise]
            false
          end
        end


        # Creates or updates this resource object. DO NOT call this method.
        # Pass modified objects  to the AuthProxy object and apply the save operation on
        # the AuthProxy object.
        #
        def save(params={})
          options = params.dup

          method = [:put,:post].include?(options[:method]) ? options[:method] : :put # hack alert
          response_handler = options[:response_handler].nil? ? self.class.get_default_response_handler : options[:response_handler]

          basic_options = self.class.get_basic_options
          cleared_options = self.class.clear_options(options)
          http_options = basic_options.merge(cleared_options)
          uri = self.create_absolute_uri

          begin
            serialized_object = self.serialize
            RestClient.send(method, uri, serialized_object, http_options, &response_handler)
          rescue Exception => e
            puts e
            raise e if options[:raise]
            false
          end
        end


        # make an alias method for save
        alias_method :update, :save


        # Deletes this resource object. DO NOT call this method.
        # Pass modified objects to the AuthProxy object and apply the delete operation on
        # the AuthProxy object.
        #
        def delete(params={})
          options = params.dup

          basic_options = self.class.get_basic_options
          cleared_options = self.class.clear_options(options)
          http_options = basic_options.merge(cleared_options)
          uri = self.absolute_uri

          begin
            response = RestClient.delete(uri, http_options)
            self.class.deserialize(response)
          rescue Exception => e
            puts e
            raise e if options[:raise]
            false
          end
        end
      end


      module ClassMethods

        # Returns a resource object with the provided id.
        def retrieve(id, options={})
          options = options.dup

          q = self.parse_query_options(options)
          uri = self.create_absolute_resource_uri(id) + q

          basic_options = self.get_basic_options
          cleared_options = self.clear_options(options)
          http_options = basic_options.merge(cleared_options)

          begin
            response = RestClient.get(uri,http_options)
            self.deserialize(response)
          rescue Exception => e
            puts e
            raise e if options[:raise]
            false
          end
        end


        # Returns a collection of resource objects..
        def all(options={})
          options = options.dup

          q = self.parse_query_options(options)
          uri = self.collection_uri + q

          filter = options[:filter].nil? ? ->(x) { true } : options[:filter] # if filter is not set, use default

          basic_options = self.get_basic_options
          cleared_options = self.clear_options(options)
          http_options = basic_options.merge(cleared_options)

          response = RestClient.get(uri,http_options)
          results = self.deserialize(response)
          results.select { |item| filter.call(item) } #filter the results
        end

      end

    end

  end

end