require 'addressable/uri'
module RestAdapter


  # Helper modules

  module Privacy
    Privat = 0
    Member = 1
    Public = 2
  end


  module Helper
    # Builds a basic auth string and returns the final basic auth string.
    # params = {username: username, password: password }
    def self.basic_auth_encryption(params)
      'Basic ' + Base64.encode64("#{params[:username]}:#{params[:password]}")
    end
  end


  # Helper classes

  # This class provides a proxy object for operation that need authentication.
  # If an operation (save,update,delete) of an object needs authentication you can use a AuthProxy object.
  # It takes care of the authentication details.
  class AuthProxy

    # Creates AuthProxy object.
    # It takes as argument an hash with the following properties:
    # { :username => a username,
    #   :password => a password,
    #   :subject => an optional subject}
    #
    # The property :subject is optional.
    #
    def initialize(params)
      @auth_header = Helper.basic_auth_encryption(username: params[:username], password: params[:password])
      @subject = params[:subject]
    end


    # Applies the save operation on the object if provided, otherwise on the subject.
    #
    # Examples====
    # user.email = 'blahaha'
    # auth_proxy.save(user)
    #
    def save(object=nil)
      params = {authorization: @auth_header}
      if not object.nil? #if object is nil, apply the op on the subject.
        object.save(params)
      elsif not @subject.nil?
          @subject.save(params)
      else
        raise 'AuthProxy does nothing'
      end
    end


    # Applies the delete operation on the object if provided, otherwise on the subject.
    #
    # Examples====
    # auth_proxy.delete(user)
    #
    def delete(object=nil)
      params = {authorization: @auth_header}
      if not object.nil? #if object is nil, apply the op on the subject.
        object.delete(params)
      elsif not @subject.nil?
        @subject.delete(params)
      else
        raise 'AuthProxy does nothing'
      end
    end

    # make a alias for method save
    alias_method :update, :save

    # Delegate each method call that is not supported by this proxy
    # to the subject.
    def method_missing(name, *args, &block)
      @subject.send(name, *args, &block)
    end

  end


  # Basic skeleton classes.

  # This class defines the basic skeleton of a resource class.
  class Resource


    # Returns an id of this object.
    def id
      self.instance_variable_get("@#{self.class.id}")
    end


    # Returns the uri of this object without the base.
    # E.g: /CyberCoachServer/resources/users/alex
    def uri
      if not defined? @uri or @uri.nil?
        self.class.site + self.class.resource_path + '/' + self.id
      else
        @uri
      end
    end


    # Returns the full uri of this object.
    # Example====
    # resource.entity_uri => http://www.blahhh.com/CyberCoachServer/resources/users/alex
    #
    def entity_uri
      self.class.base + self.uri
    end

    # Class methods for the class resource.
    # open the eigenclass
    class << self

      # create setters and getters for class variables
      attr_reader :resource_name, :resource_path, :id, :resource_name_plural

      # Cyber coach basic config values.
      # All subclasses share the same base, site and format variables.
      @@base = 'http://diufvm31.unifr.ch:8090'
      @@site = '/CyberCoachServer/resources'
      @@format = :xml #used for http accept and content-type header



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

      def format
        @@format
      end


      # Setter and getters for class variables.


      # Sets the id variable for this class.
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


      # Maps the resource for this class.
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


      # Creates an entity uri with the passed id
      # Example====
      # Resource.create_entity_uri 'alex' => http://www.blahhh.com/CyberCoachServer/resources/users/alex
      #
      def create_entity_uri(id)
        base + site + resource_path + '/' + id.to_s
      end

    end # end of eigenclass

  end # end of class Resource


  # This class implements common instance and class methods
  # that all resources have in common..
  class BaseResource < Resource

    # Fetches all details of this object and returns a object
    # containing all details.
    #
    def fetch
      begin
        uri = self.entity_uri
        response = RestClient.get(uri, {
            content_type: self.class.format,
            accept: self.class.format
        })
        # get deserializer
        self.class.deserialize(response)
      rescue Exception => e
        puts e
        false
      end
    end


    # Fetches all detail information of this object and modifies its internal properties
    # according the fetched details.
    #
    def fetch!
      begin
        uri = self.entity_uri
        response = RestClient.get(uri, {
            content_type: self.class.format,
            accept: self.class.format
        })

        obj = self.class.deserialize(response)
        variables = obj.instance_variables
        variables.each do |variable|
          self.instance_variable_set(variable, obj.instance_variable_get(variable))
        end
      rescue Exception => e
        puts e
        false
      end
    end


    # Creates or updates this object. DO NOT call this method.
    # Pass modified objects  to the AuthProxy object and apply the save operation on
    # the AuthProxy object.
    #
    def save(params={})
      # basic options
      options = {
          accept: self.class.format,
          content_type: self.class.format
      }
      options = options.merge(params)

      begin
        uri = self.class.create_entity_uri(self.id)
        serialized_object = self.class.serialize(self)
        response = RestClient.put(uri, serialized_object, options)
        self.class.deserialize(response)
      rescue Exception => e
        puts e
        false
      end
    end


    # make an alias method for save
    alias_method :update, :save


    # Deletes this object. DO NOT call this method.
    # Pass modified objects to the AuthProxy object and apply the delete operation on
    # the AuthProxy object.
    #
    def delete(params={})
      # basic options
      options = {
          accept: self.class.format,
          content_type: self.class.format
      }
      options = options.merge(params)
      uri = self.entity_uri
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

      # This class method creates a new resource given the parameters by the deserializer class method.
      # Each class that subclasses this class MUST implement such a create class method.
      def create(params)
        raise 'Not implemented'
      end


      # This class deserializes the received response of a rest client and delegates the object creation to
      # its subclasses.
      def deserialize(response)
        hash = Hash.from_xml(response)
        if not hash['list'].nil? # check if it's a list of resources
          resources = hash['list'][self.resource_name_plural][self.resource_name]
          objs = resources.map do |resource|
            self.create resource # call template method 'create'
          end
        else # otherwise it is a single resource
          obj = self.create hash[self.resource_name] # call template method 'create'
        end
      end


      # Returns a resource with the provided id.
      def retrieve(id)
        begin
          uri = self.create_entity_uri(id)
          response = RestClient.get(uri, {
              content_type: self.format,
              accept: self.format
          })
          self.deserialize(response)
        rescue Exception => e
            puts e
            false
        end
      end


      # Returns a collection of resources.
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
            content_type: self.format,
            accept: self.format
        })
        filter = params[:filter]
        results = self.deserialize(response)
        results = results.select { |item| filter.call(item) }
      end

    end # end of eigenclass

  end # end of class BaseResource



  # Basic adapter classes

  # This class adapts the resource user.
  class User < BaseResource

    # set user resource specific config values
    set_id :username
    set_resource_path '/users'
    set_resource 'user'

    # getters and setters
    attr_accessor :username, :password, :email, :real_name, :partnerships, :public_visible


    # Creates a user object.
    def initialize(params={})
      # default value for all properties is nil
      @username = params[:username]
      @password = params[:password]
      @email = params[:email]
      @uri = params[:uri]
      @real_name = params[:real_name]
      @public_visible = params[:public_visible]
      @partnerships = params[:partnerships]
    end


    # open eigenclass
    class << self

      # This class method is called by the deserialize class method from the base resource class.
      # It is responsible for creating a user object.
      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash'
        end

        properties = {
            username: params['username'],
            email: params['email'],
            password: nil, #otherwise we get garbage, because default is a star (*)
            uri: params['uri'],
            real_name: params['realname'],
            public_visible: params['publicvisible'].to_i
        }

        new(properties)
      end


      def serialize(user)
        if not user.kind_of?(User)
          raise ArgumentError, 'Argument must be of type user'
        end

        hash = {
            email: user.email,
            publicvisible: user.public_visible.to_s,
            realname: user.real_name,
        }

        if not user.password.nil? and not user.password.empty?
          hash = hash.merge({password: user.password})
        end

        hash.to_xml(root: 'user')
      end


      # Authenticates a user against the cyber coach webservice.
      # It uses a hash as argument with the following properties:
      # params = { username: username, password: password }
      #
      def authenticate(params)
        begin
          response = RestClient.get(self.base + self.site + '/authenticateduser/', {
              content_type: self.format,
              accept: self.format,
              authorization: Helper.basic_auth_encryption(params)
          })
          user = self.deserialize(response)
          AuthProxy.new username: params[:username], password: params[:password], subject: user
        rescue
          false
        end
      end


      # Checks if a user name is available on the cyber coach webservice.
      # Returns false if the username is already taken or if the username is not alphanumeric string with at least 4 letters.
      # Otherwise it returns true.
      # It uses a string as fir the argument username.
      #
      def username_available?(username)
        # check if username is alphanumeric and that it contains least 4 letters
        if  not /^[a-zA-Z0-9]{4,}$/ =~ username
          return false
        end
        # try and error: check if username is already used... i'm feeling dirty...
        begin
          uri = self.create_entity_uri(username)
          response = RestClient.get(uri, {
              content_type: self.format,
              accept: self.format
          })
          false
        rescue
          true
        end
      end

    end  # end of eigenclass

  end # end of class User


  # This class adapts the resource partnership.
  class Partnership < BaseResource

    set_resource_path '/partnerships'
    set_resource 'partnership'

    # getters and setters

    attr_reader :public_visible, :confirmed_by_first_user, :confirmed_by_second_user, :first_user, :second_user

    alias_method :confirmed_by_first_user?, :confirmed_by_first_user
    alias_method :confirmed_by_second_user?, :confirmed_by_second_user

    # Define customized id for partnership
    def id
      self.first_user.username + ';' + self.second_user.username
    end


    # Creates a partnership object.
    def initialize(params)
      # default value for all properties is nil
      @uri = params[:uri]
      @public_visible = params[:public_visible]
      @confirmed_by_first_user = params[:confirmed_by_first_user]
      @confirmed_by_second_user = params[:confirmed_by_second_user]
      @first_user = params[:first_user]
      @second_user = params[:second_user]
    end


    # Returns true if the given user is associated with this partnership.
    def associated_with?(user)
      username = user.kind_of?(User) ? user.username : user
      user_names = self.class.extract_user_names_from_uri(self.uri)
      user_names.include?(username)
    end


    # open eigenclass
    class << self

      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash'
        end

        properties = {
            uri: params['uri'],

        }

        new(properties)
      end


      def serialize(partnership)
        if not user.kind_of?(User)
          raise ArgumentError, 'Argument must be of type partnership'
        end
        hash = {
            publicvisible: partnership.public_visible
        }
        hash.to_xml(root: 'partnership')
      end


      def extract_user_names_from_uri(uri)
        resource = uri.split('/').last # get last part of the uri
        resource = resource[0...-1] if resource[-1] == '/' # remove last forward slash if present
        resource.split(';')
      end

    end # end of eigenclass

  end # end of class Partnership


  # This class adapts the resource partnership.
  class Sport < BaseResource

    attr_reader :name, :id

    set_resource_path '/sports'
    set_resource 'sport'


    def initialize(params)
      @name = params[:name]
      @id = params[:id]
      @uri = params[:uri]
    end


    # open eigenclass
    class << self

      def create(params)
        new({
                name: params['name'],
                id: params['id'],
                uri: params['uri']
            })
      end

    end # end of eigenclass

  end # end of class Sport

end