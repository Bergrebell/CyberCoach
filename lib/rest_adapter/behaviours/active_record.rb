module RestAdapter

  module Behaviours

    module ActiveRecord

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods, Helper

        # Required class methods (preconditions) which must be implemented for using this behaviour.
        raise 'ActiveRecord#deserialize() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize
        raise 'ActiveRecord#serialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.serialize_format
        raise 'ActiveRecord#deserialize_format() is not implemented! Precondition is not satisfied.' if not defined? base.deserialize_format
      end


      module InstanceMethods

        # Fetches all details for this resource object and returns a object
        # containing all details.
        #
        def fetch(options={})
          q = self.class.parse_query_options(options)
          begin
            uri = self.absolute_uri + q
            response = RestClient.get(uri, {
                content_type: self.class.serialize_format,
                accept: self.class.deserialize_format
            })
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
          q = self.class.parse_query_options(options)
          begin
            uri = self.absolute_uri + q
            response = RestClient.get(uri, {
                content_type: self.class.serialize_format,
                accept: self.class.deserialize_format
            })

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
        def save(params={})
          # basic options
          options = {
              accept: self.class.deserialize_format,
              content_type: self.class.serialize_format,
          }
          method = [:put,:post].include?(params[:method]) ? params[:method] : :put # hack alert

          # hack alert
          default_response_handler = proc do |response, request, result|
            return self.class.deserialize(response)
          end
          response_handler = params[:response_handler].nil? ? default_response_handler : params[:response_handler]

          params.delete(:method)
          params.delete(:response_handler)
          options = options.merge(params)

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


      module Helper
        def parse_query_options(options)
          # if query is not set, use default
          if options[:query].nil?
            options = options.merge({query: {start: 0, size: 999}})
          end

          # build query
          uri = Addressable::URI.new
          uri.query_values = options[:query]
          q = '?' + uri.query
        end
      end


      module ClassMethods

        # Returns a resource object with the provided id.
        def retrieve(id, options={})
          q = parse_query_options(options)
          begin
            uri = self.create_absolute_resource_uri(id) + q
            response = RestClient.get(uri, {
                content_type: self.serialize_format,
                accept: self.deserialize_format
            })
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

          q = parse_query_options(params)
          response = RestClient.get(self.collection_uri + q, {
              content_type: self.serialize_format,
              accept: self.deserialize_format
          })
          filter = params[:filter]
          results = self.deserialize(response)
          results = results.select { |item| filter.call(item) } #filter the results
        end

      end

    end

  end

end