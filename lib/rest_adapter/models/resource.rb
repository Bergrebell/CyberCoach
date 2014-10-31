module RestAdapter

  module Models

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
      # object.uri =>  /CyberCoachServer/resources/users/alex
      def uri
        if @uri.nil?
          self.class.site + self.class.resource_path + '/' + self.id
        else
          @uri
        end
      end

      # Returns the uri of a single resource entity.
      # Example====
      # object.absolute_uri => http://www.blahhh.com/CyberCoachServer/resources/users/alex
      #
      def absolute_uri
        self.class.base + self.uri
      end

      # Creates an entity uri with the given id.
      # Example====
      # object.create_absolute_uri 'alex' => http://www.blahhh.com/CyberCoachServer/resources/users/alex
      #
      def create_absolute_uri
        self.class.base + self.class.site + self.class.resource_path + '/' + id.to_s
      end


      def resource_path
        self.class.resource_path
      end


      # Class methods for the resource class.
      # open eigenclass
      class << self

        # Template methods / Hook up methods

        # Getters for meta class variables.
        def base
          raise 'Not specified!'
        end

        def site
          raise 'Not specified!'
        end

        def create(params)
          raise 'Not implemented!'
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


        def id
          @id
        end


        # Sets the resource path for this resource class.
        # Example====
        # set_resource_path 'users' => '/users
        #
        def set_resource_path(resource_path)
          @resource_path = resource_path
        end


        def resource_path
          @resource_path
        end


        # Maps the given resource to this resource class.
        # Eexample====
        # set_resource 'user'
        #
        def set_resource(resource_name)
          @resource_name = resource_name
          @resource_name_plural = @resource_name.pluralize
        end


        def resource_name
          @resource_name
        end


        def resource_name_plural
          @resource_name_plural
        end

        # Returns the collection uri of this resource.
        # Example====
        # Class.collection_uri => http://www.blahhh.com/CyberCoachServer/resources/users
        #
        def collection_uri
          # base/site/path
          base + site + resource_path
        end


        # Creates an entity uri with the given id.
        # Example====
        # Class.create_absolute_resource_uri 'alex' => http://www.blahhh.com/CyberCoachServer/resources/users/alex
        #
        def create_absolute_resource_uri(id)
          base + site + resource_path + '/' + id.to_s
        end

      end # end of eigenclass

    end # end of class Resource
  end
end