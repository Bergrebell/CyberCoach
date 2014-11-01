module RestAdapter

  module Behaviours

    module ActiveRecord

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods

        # Required class methods (preconditions) which must be implemented for using this behaviour.
        raise 'ActiveRecord#deserialize() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize
        raise 'ActiveRecord#serialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.serialize_format
        raise 'ActiveRecord#deserialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize_format
      end

      # module helper class methods

      def self.parse_query_options(options)
        # if query is not set, use default
        if options[:query].nil?
          options = options.merge({query: {start: 0, size: 999}})
        end

        # build query
        uri = Addressable::URI.new
        uri.query_values = options[:query]
        q = '?' + uri.query
      end


      def self.get_basic_options
        {content_type: self.serialize_format,
         accept: self.deserialize_format}
      end


      def self.get_default_response_handler
        proc do |response, request, result|
          return self.deserialize(response)
        end
      end


      module InstanceMethods

        # Fetches all details for this resource object and returns a object
        # containing all details.
        #
        def fetch(options={})
          q = ActiveRecord.parse_query_options(options)
          begin
            uri = self.absolute_uri + q
            options = self.class.get_basic_options
            response = RestClient.get(uri, options)
            # get deserializer
            self.class.deserialize(response)
          rescue Exception => e
            puts e
            false
          end
        end


        # Fetches all detail information of this resource object and modifies its internal properties
        # according the fetched details.
        #
        def fetch!(options={})
          q = self.parse_query_options(options)
          begin
            uri = self.absolute_uri + q
            options = self.class.get_basic_options
            response = RestClient.get(uri, options)

            obj = self.class.deserialize(response)
            variables = obj.instance_variables
            variables.each do |variable|
              self.instance_variable_set(variable, obj.instance_variable_get(variable))
            end
            obj
          rescue Exception => e
            puts e
            false
          end
        end


        # Creates or updates this resource object. DO NOT call this method.
        # Pass modified objects  to the AuthProxy object and apply the save operation on
        # the AuthProxy object.
        #
        def save(options={})
          options = options.dup
          # basic options
          basic_options = ActiveRecord.get_basic_options
          method = [:put,:post].include?(options[:method]) ? options[:method] : :put # hack alert

          response_handler = options[:response_handler].nil? ? ActiveRecord.get_default_response_handler : options[:response_handler]

          options.delete(:method)
          options.delete(:response_handler)
          options = basic_options.merge(options)

          begin
            uri = self.create_absolute_uri
            serialized_object = self.serialize
            RestClient.send(method, uri, serialized_object, options, &response_handler)
          rescue Exception => e
            puts e
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
          # basic options
          options = {
              accept: self.class.deserialize_format,
              content_type: self.class.serialize_format
          }
          options = options.merge(params)
          uri = self.absolute_uri
          begin
            response = RestClient.delete(uri, options)
            self.class.deserialize(response)
          rescue Exception => e
            puts e
            false
          end
        end
      end





      module ClassMethods

        # Returns a resource object with the provided id.
        def retrieve(id, options={})
          q = ActiveRecord.parse_query_options(options)
          options = options.dup
          options.delete(:query)
          basic_options = {
              content_type: self.serialize_format,
              accept: self.deserialize_format
          }

          basic_options = options.merge(basic_options)

          begin
            uri = self.create_absolute_resource_uri(id) + q
            response = RestClient.get(uri,basic_options)
            self.deserialize(response)
          rescue Exception => e
            puts e
            false
          end
        end


        # Returns a collection of resource objects..
        def all(params={})
          # if filter is not set, use default
          if params[:filter].nil?
            params = params.merge({filter: ->(x) { true }})
          end

          basic_options = {
              content_type: self.serialize_format,
              accept: self.deserialize_format
          }

          q = ActiveRecord.parse_query_options(params)
          response = RestClient.get(self.collection_uri + q,basic_options)
          filter = params[:filter]
          results = self.deserialize(response)
          results = results.select { |item| filter.call(item) } #filter the results
        end

      end

    end

  end

end