module RestAdapter

  # This class defines the basic skeleton of a resource class.
  # It defines which methods or class methods that need to be
  # implemented by the subclasses.
  class Resource

    def __initialize(params={})
      props = Hash[params.map {|k,v| [k.to_sym,v]}]
      props.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
    end

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

    # Returns the uri of a single resource entity.
    # Example====
    # resource.entity_uri => http://www.blahhh.com/CyberCoachServer/resources/users/alex
    #
    def absolute_uri
      self.class.base + self.uri
    end

    # Creates an entity uri with the given id.
    # Example====
    # resource.create_entity_uri 'alex' => http://www.blahhh.com/CyberCoachServer/resources/users/alex
    #
    def create_absolute_uri
      self.class.base + self.class.site + self.class.resource_path + '/' + id.to_s
    end


    # Class methods for the resource class.
    # open eigenclass
    class << self

      # create setters and getters for class variables
      attr_reader :resource_name, :resource_path, :id, :resource_name_plural


      # All subclasses share the same base, site and format variables.
      #@@base = 'http://diufvm31.unifr.ch:8090'
      #@@site = '/CyberCoachServer/resources'
      #@@deserialize_format = :json #use json as default value for http header accept
      #@@serialize_format = :xml #use json as default value for http header content-type

      def module_name
        Module.nesting.last
      end


      # Template methods / Hook up methods

      # Getters for meta class variables.
      def base
        raise 'Not specified!'
      end

      def site
        raise 'Not specified!'
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
      def create_absolute_resource_uri(id)
        base + site + resource_path + '/' + id.to_s
      end

    end # end of eigenclass

  end # end of class Resource
end