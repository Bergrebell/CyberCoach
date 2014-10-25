module RestAdapter

  # This class implements common instance and class methods
  # that all resources have in common.
  class BaseResource < Resource

    # Fetches all details for this resource object and returns a object
    # containing all details.
    #
    def fetch(options={}) # TODO: fix options
      # if query is not set, use default
      if options[:query].nil?
        options = options.merge({query: {start: 0, size: 999}})
      end

      # build query
      uri = Addressable::URI.new
      uri.query_values = options[:query]
      q = '?' + uri.query
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
    def fetch!(options={}) # TODO: fix options
      # if query is not set, use default
      if options[:query].nil?
        options = options.merge({query: {start: 0, size: 999}})
      end
      # build query
      uri = Addressable::URI.new
      uri.query_values = options[:query]
      q = '?' + uri.query

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
          content_type: self.class.serialize_format
      }
      options = options.merge(params)

      begin
        uri = self.create_absolute_uri
        serialized_object = self.class.serialize(self)
        response = RestClient.put(uri, serialized_object, options)
        self.class.deserialize(response)
      rescue Exception => e
        puts e
        raise e
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


    # class methods for the user resource
    # open eigenclass
    class << self

      # This class method creates a new resource given the parameters by the deserialize class method.
      # Each class that subclasses this class MUST implement such a create class method.
      def create(params)
        raise 'Not implemented'
      end

      def available
        @available
      end

      # This class method deserializes the received response of a rest client
      # and delegates the object creation to its subclasses.
      def __deserialize(response)
        hash = Hash.from_xml(response)
        if not hash['list'].nil? # check if it's a list of resources
          @available = hash['list']['available'].to_i
          @start = hash['list']['start'].to_i
          @end = hash['list']['end'].to_i

          if hash['list'][self.resource_name_plural][self.resource_name].kind_of?(Array)
            resources = hash['list'][self.resource_name_plural][self.resource_name]
          else
            resources = [] << hash['list'][self.resource_name_plural][self.resource_name]
          end


          objs = resources.map do |resource|
            self.create resource # call template method 'create'
          end
        else # otherwise it is a single resource
          obj = self.create hash[self.resource_name] # call template method 'create'
        end
      end

      # This class method deserializes the received response of a rest client
      # and delegates the object creation to its subclasses.
      def deserialize(response)
        hash = JSON.parse(response)
        if not hash[self.resource_name_plural].nil? # check if it's a list of resources
          @available = hash['available'].to_i
          @start = hash['start'].to_i
          @end = hash['end'].to_i
          resources = hash[self.resource_name_plural]
          objs = resources.map do |resource|
            self.create resource # call template method 'create'
          end
        else # otherwise it is a single resource
          obj = self.create hash # call template method 'create'
        end
      end


      # Returns a resource object with the provided id.
      def retrieve(id,options={ }) # TODO: fix options
        # if query is not set, use default
        if options[:query].nil?
          options = options.merge({query: {start: 0, size: 999}})
        end

        # build query
        uri = Addressable::URI.new
        uri.query_values = options[:query]
        q = '?' + uri.query

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
        # if query is not set, use default
        if params[:query].nil?
          params = params.merge({query: {start: 0, size: 999}})
        end

        # if filter is not set, use default
        if params[:filter].nil?
          params = params.merge({filter: ->(x) { true }})
        end

        # build query
        uri = Addressable::URI.new
        uri.query_values = params[:query]
        q = '?' + uri.query

        response = RestClient.get(self.collection_uri + q, {
            content_type: self.serialize_format,
            accept: self.deserialize_format
        })
        filter = params[:filter]
        results = self.deserialize(response)
        results = results.select { |item| filter.call(item) } #filter the results
      end

    end # end of eigenclass

  end # end of class BaseResource
end