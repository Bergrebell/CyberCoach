module RestAdapter

  # This class implements common instance and class methods
  # that all resources have in common.
  class BaseResource < Resource

    def initialize(params={})
      super(params)
      create_lazy_loading_getters
      inject_dependencies
    end

    private

    def inject_dependencies
      self.class.dependencies.each do |property,clazz|
        if instance_variable_get("@#{property}").is_a?(Hash)
          object = clazz.call(instance_variable_get("@#{property}"))
          instance_variable_set("@#{property}",object)
        elsif instance_variable_get("@#{property}").is_a?(Array)
          objects = Array.new
            instance_variable_get("@#{property}").each do |v|
              (objects << clazz.call(v)) if v.is_a?(Hash)
          end
          instance_variable_set("@#{property}",objects) if not objects.empty?
        end
      end
    end


    # Creates lazy loading getters for properties that are configured as lazy properties.
    def create_lazy_loading_getters
      self.class.lazy_loading_properties.each do |property|
        define_singleton_method(property) do
          if  instance_variable_get("@#{property}").nil?
            self.fetch!
          end
          if instance_variable_get("@#{property}").nil? and property[-1] == 's' # hack alert
            []
          else
            instance_variable_get("@#{property}")
          end
        end
      end
    end

    public

    # Fetches all details for this resource object and returns a object
    # containing all details.
    #
    def fetch
      begin
        uri = self.absolute_uri
        response = RestClient.get(uri, {
            content_type: self.class.serialize_format,
            accept: self.class.deserialize_format
        })
        # get deserializer
        self.class.deserialize(response)
      rescue Exception => e
        raise e
        puts e
        false
      end
    end


    # Fetches all detail information of this resource object and modifies its internal properties
    # according the fetched details.
    #
    def fetch!
      begin
        uri = self.absolute_uri
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


    def valid?
      booleans = self.class.validators.map {|property,validator| validate(property) }
      booleans.reduce {|acc,result| acc &&= result }
    end


    def validate(property)
      variable_name = "@#{property}".to_sym
      validator = self.class.validators[property]
      !validator.nil? ? validator.call(instance_variable_get(variable_name)) : false
    end


    def serialize
      self.class.serialize(self)
    end


    # class methods for the user resource
    # open eigenclass
    class << self


      def available
        @available
      end

      # This class method defines on which properties lazy loading will be applied.
      # Lazy loading on a property will automatically fetch the missing property.
      #
      def lazy_loading_on(*properties)
        @lazy_loading_properties = properties
      end


      # Returns a list of properties where lazy loading is applied.
      #
      def lazy_loading_properties
        @lazy_loading_properties.nil? ? Array.new : @lazy_loading_properties
      end


      def present?(value)
        not value.nil?
      end

      def validates(params)
        @validators = Hash.new if @validators.nil?
        params.each do |key,validator|
          @validators[key] = validator if validator.is_a?(Proc)
          @validators[key] = ->(property) { self.send(validator, property) } if validator.is_a?(Symbol)
        end
      end

      def validators
        @validators.nil? ? Hash.new : @validators
      end


      def serialize(object)
        raise ArgumentError, 'Argument must be an object!' if not object.is_a?(Object)
        filtered_properties, properties = Hash.new, object.as_hash
        serializable_properties.each do |key|
          string_key = key.to_s
          mapped_key = string_key.tr('_', '') # automatically map public_visible to publicvisible
          if not properties[string_key].nil? # do not serialize properties that are nil
            validator = validators[key].nil? ? ->(x) {true} : validators[key] # use validator fun if available otherwise use true validator
            #automatically map to a string
            filtered_properties = filtered_properties.merge({mapped_key => properties[string_key].to_s}) if validator.call(key)
          end
        end
        filtered_properties.to_xml(root: resource_name)
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


      # Creates an object of this resource.
      def create(params)
        hash = Hash.new
        deserializable_properties.each do |key|
          if key.is_a?(Hash)
            key.each do |mapped_key, property_key|
              mapped_string_key = mapped_key.to_s
              hash = hash.merge({property_key => params[mapped_string_key]})
            end
          else
            mapped_string_key = key.to_s.tr('_', '')
            hash = hash.merge({key => params[mapped_string_key]})
          end
        end

        sub_hash = after_deserializer.call(params)
        hash = hash.merge(sub_hash) if not sub_hash.nil?

        self.new hash # create object
      end


      def after_deserialize(&mapper)
        @mapper = mapper
      end

      def after_deserializer
        @mapper.nil? ? ->(x) { nil } : @mapper
      end


      def inject(dependencies)
        @dependencies = Hash[dependencies.map {|key,clazz| [key, !clazz.is_a?(Proc) ? ->(x) {clazz.create(x)} : clazz] }]
      end

      def dependencies
        @dependencies.nil? ? Array.new : @dependencies
      end


      # Returns a resource object with the provided id.
      def retrieve(id)
        begin
          uri = self.create_absolute_resource_uri(id)
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