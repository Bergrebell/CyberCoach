module RestAdapter

  # This class defines the basic skeleton of a resource class.
  # It defines which methods or class methods that need to be
  # implemented by the subclasses.
  class Resource

    # Returns an id of this resource.
    def id
      self.instance_variable_get("@#{self.class.id}")
    end


    # Returns the uri of this resource without the base.
    # Example====
    # resource.uri =>  /CyberCoachServer/resources/users/alex
    def uri
      if not defined? @uri or @uri.nil?
        self.class.site + self.class.resource_path + '/' + self.id
      else
        @uri
      end
    end

    # Returns a hash representation of this resource.
    # As argument it takes an optional hash with two properties :included_keys and :excluded_keys
    # The hash is filtered according the two lists that are provided by :included_keys and :excluded_keys.
    #
    # Examples====
    # user.as_hash(included_keys: [:username,:email]) => { username: 'blah', email: 'blah'}
    # user.as_hash(excluded_keys: [:username,:email]) => hash does not have the properties username and email
    #
    def as_hash(params={})
      # hack alert
      json_string = self.to_json
      hash = JSON.parse(json_string)
      if not params[:included_keys].nil?
        included_keys = Hash[params[:included_keys].map {|k,v| [k.to_s,v]}]
        hash = hash.select { |key,_| included_keys.include? key }
      end

      if not params[:excluded_keys].nil?
        excluded_keys = Hash[params[:excluded_keys].map {|k,v| [k.to_s,v]}]
        hash = hash.select { |key,_| not excluded_keys.include? key }
      end
      hash
    end


    # Returns the uri of a single resource entity.
    # Example====
    # resource.entity_uri => http://www.blahhh.com/CyberCoachServer/resources/users/alex
    #
    def entity_uri
      self.class.base + self.uri
    end


    # Class methods for the resource class.
    # open eigenclass
    class << self

      # create setters and getters for class variables
      attr_reader :resource_name, :resource_path, :id, :resource_name_plural

      # Cyber coach basic config values.
      # All subclasses share the same base, site and format variables.
      @@base = 'http://diufvm31.unifr.ch:8090'
      @@site = '/CyberCoachServer/resources'
      @@default_deserialize_format = :json #use json as default value for http header accept
      @@default_serialize_format = :xml #use json as default value for http header content-type


      # Template methods / Hook up methods


      # This class method serializes the passed object.
      # Each subclass MUST implement this class method.
      def serialize(object)
        raise 'Not implemented!'
      end


      # This class method deserializes the passed object.
      # Each subclass MUST implement this class method.
      def deserialize(object)
        raise 'Not implemented!'
      end


      # Getters for meta class variables.
      def base
        @@base
      end

      def site
        @@site
      end

      # Returns the format that is used.
      # If format is not specified a default value is used.
      def deserialize_format
        !@deserialize_format.nil? ? @deserialize_format : @@default_deserialize_format
      end


      # Returns the format that is used.
      # If not format is specified a default value is used.
      def serialize_format
        !@serialize_format.nil? ? @serialize_format : @@default_serialize_format
      end

      # Sets the format for this resource.
      # Can be :xml, :json, or :html .
      def set_deserialize_format(format)
        @deserialize_format = format
      end

      # Sets the format for this resource.
      # Can be :xml, :json, or :html .
      def set_serialize_format(format)
        @serialize_format = format
      end


      # Setter and getters for class variables.


      # Sets the id variable for this resource class.
      # Examples====
      # set_id :username        => instance variable @username is used as id
      # user.id                 => returns @username
      #
      def set_id(id)
        @id = id
      end


      # Sets the resource path for this resource class.
      # Example====
      # set_resource_path 'users' => '/users
      #
      def set_resource_path(resource_path)
        @resource_path = resource_path
      end


      # Maps the given resource to this resource class.
      # Eexample====
      # set_resource 'user'
      #
      def set_resource(resource_name)
        @resource_name = resource_name
        @resource_name_plural = @resource_name.pluralize
      end


      # Returns the collection uri of this resource.
      # Example====
      # Resource.collection_uri => http://www.blahhh.com/CyberCoachServer/resources/users
      #
      def collection_uri
        # base/site/path
        base + site + resource_path
      end


      # Creates an entity uri with the given id.
      # Example====
      # Resource.create_entity_uri 'alex' => http://www.blahhh.com/CyberCoachServer/resources/users/alex
      #
      def create_entity_uri(id)
        base + site + resource_path + '/' + id.to_s
      end

    end # end of eigenclass

  end # end of class Resource
end