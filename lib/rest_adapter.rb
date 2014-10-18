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

  # This class is responsible for providing access for authentication protected operations.
  # An operation like save, update or delete applied on a object needs authentication.
  # To hide the details and to provide a common interface you can use a AuthProxy object.
  class AuthProxy

    attr_accessor :subject, :auth_params
    # Creates AuthProxy object.
    # It takes as argument a hash with the following properties:
    # { :username => a username,
    #   :password => a password,
    #   :subject => an optional subject}
    #
    # or alternatively a hash as follows:
    # { :user => a user object,
    #   :subject => an optional subject}
    #
    # The property :subject is optional.
    #
    def initialize(params)
      @auth_params = if not params[:user].nil?
        {
            username: params[:user].username,
            password: params[:user].password
        }
      else
        {
            username: params[:username],
            password: params[:password]
        }
      end

      @subject = params[:subject]
      @auth_header = Helper.basic_auth_encryption(@auth_params)
    end

    # Checks if this AuthProxy object is valid in terms of the user credentials.
    # For validation an authentication request is performed.
    # Only for testing purposes!
    def valid?
      User.authenticate(@auth_params) != false
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


    # Delegates each method call that is not supported by this proxy
    # to the subject.
    def method_missing(name, *args, &block)
      # This is basically used for wrapping a user object.
      # The only simple way to get the user credentials without dirty hacking
      # is in the authenticate class method in the User class.
      # Instead of returning a User object the authenticate class method returns a AuthProxy object
      # which acts like user object.
      # So here the user object plays the role of the subject.

      @subject.send(name, *args, &block)
    end

  end


  # Basic skeleton classes: Resource, BaseResource

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
    def as_hash
      # hack alert
      json_string = self.to_json
      hash = JSON.parse(json_string)
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


  # This class implements common instance and class methods
  # that all resources have in common.
  class BaseResource < Resource

    # Fetches all details for this resource object and returns a object
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


    # Fetches all detail information of this resource object and modifies its internal properties
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


    # Deletes this resource object. DO NOT call this method.
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

      # This class method creates a new resource given the parameters by the deserialize class method.
      # Each class that subclasses this class MUST implement such a create class method.
      def create(params)
        raise 'Not implemented'
      end


      # This class method deserializes the received response of a rest client
      # and delegates the object creation to its subclasses.
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


      # Returns a resource object with the provided id.
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
            content_type: self.format,
            accept: self.format
        })
        filter = params[:filter]
        results = self.deserialize(response)
        results = results.select { |item| filter.call(item) } #filter the results
      end

    end # end of eigenclass

  end # end of class BaseResource



  # Basic adapter classes for the resources User, Partnership, Sport, Subscription

  # This class is responsible for adapting the resource user.
  class User < BaseResource

    # set user resource specific config values
    set_id :username
    set_resource_path '/users'
    set_resource 'user'

    # getters and setters
    attr_accessor :username, :password


    # Creates a user object.
    def initialize(params={})
      # Support string keys too, because rails maps symbols to string keys...
      params = Hash[params.map {|k,v| [k.to_sym,v]}]
      # default value for all properties is nil
      @username = params[:username]
      @password = params[:password]
      @email = params[:email]
      @uri = params[:uri]
      @real_name = params[:real_name]
      @public_visible = params[:public_visible]
      @partnerships = params[:partnerships]
    end


    # Returns all friends of this user.
    def friends
      partnerships = self.partnerships.map {|p| p.fetch } # fetch all details
      active_partnerships = partnerships.select {|p| p.active? } # filter, only get active partnerships
      friends = active_partnerships.map {|p| p.partner_of(self) } # get users instead of partnerships
    end


    # Returns all received friend requests of this user.
    def received_friend_requests
      partnerships = self.partnerships.map {|p| p.fetch } # fetch all details
      proposed_partnerships = partnerships.select {|p| not p.confirmed_by?(self) } # filter, only get proposed partnerships
      friends = proposed_partnerships.map {|p| p.partner_of(self) } # get users instead of partnerships
    end


    # Returns all sent friend requests of this user.
    def sent_friend_requests
      partnerships = self.partnerships.map {|p| p.fetch } # fetch all details
      proposed_partnerships = partnerships.select {|p| p.confirmed_by?(self) and not p.active? }
      friends = proposed_partnerships.map {|p| p.partner_of(self) } # get users instead of partnerships
    end


    #should we apply 'hidden lazy loading' on missing data ???

    def partnerships
      # if nil fetch some data
      if @partnerships.nil?
        self.fetch!
      end
      # if still nil, return empty list
      if @partnerships.nil?
        []
      else
        @partnerships
      end
    end


    def partnerships=(partnerships)
      @partnerships = partnerships
    end


    def email
      if @email.nil?
        self.fetch!
      end
      @email
    end


    def email=(email)
      @email = email
    end


    def real_name
      if @real_name.nil?
        self.fetch!
      end
      @real_name
    end


    def real_name=(real_name)
      @real_name = real_name
    end


    def public_visible
      if @public_visible.nil?
        self.fetch!
      end
      @public_visible
    end


    def public_visible=(public_visible)
      @public_visible = public_visible
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

        if not params['partnerships'].nil?
          # really, really ugly
          if params['partnerships']['partnership'].kind_of?(Array)
            partnerships =  params['partnerships']['partnership'].map {|p| Partnership.create p }
          else
            partnerships = [Partnership.create(params['partnerships']['partnership'])]
          end
          properties = properties.merge({partnerships: partnerships})
        end

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
      # params = {
      #           username: username,
      #           password: password
      # }
      # Remark: http://stackoverflow.com/questions/22978704/object-stored-in-rails-session-becomes-a-string
      # God dammit, rails cannot store objects in a session variable...
      #
      def authenticate(params)
        begin
          response = RestClient.get(self.base + self.site + '/authenticateduser/', {
              content_type: self.format,
              accept: self.format,
              authorization: Helper.basic_auth_encryption(params)
          })
          user = self.deserialize(response)
          user.password = params[:password]
          user
        rescue
          false
        end
      end


      # Checks if a username is available on the cyber coach webservice.
      # Returns false if the username is already taken or the username is not a alphanumeric string
      # with at least 4 letters. Otherwise it returns true.
      #
      def username_available?(username)
        # check if username is alphanumeric and that it contains at least four letters
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


  # This class is responsible for adapting the resource partnership.
  class Partnership < BaseResource

    #getters and setters
    attr_reader :public_visible, :confirmed_by_first_user, :confirmed_by_second_user,
                :first_user, :second_user, :confirmed
    set_resource_path '/partnerships'
    set_resource 'partnership'

    alias_method :confirmed_by_first_user?, :confirmed_by_first_user
    alias_method :confirmed_by_second_user?, :confirmed_by_second_user

    # Defines a customized id for a partnership resource.
    def id
      self.first_user.username + ';' + self.second_user.username
    end


    # Creates a partnership object.
    def initialize(params)
      # default value for all properties is nil!
      @uri = params[:uri]
      @public_visible = params[:public_visible]
      @confirmed_by_first_user = params[:confirmed_by_first_user]
      @confirmed_by_second_user = params[:confirmed_by_second_user]
      @first_user = params[:first_user]
      @second_user = params[:second_user]
      @confirmed = params[:confirmed]
    end


    # Returns true if the given user is associated with this partnership.
    def associated_with?(user)
      username = user.kind_of?(User) ? user.username : user # support usernames and user object
      user_names = self.class.extract_user_names_from_uri(self.uri)
      user_names.include?(username)
    end


    # Returns true if the given user has confirmed this partnership.
    def confirmed_by?(user)
      username = user.kind_of?(User) ? user.username : user # support usernames and user object

      # check if confirmed lookup table is present
      if self.confirmed.nil?
        self.fetch! #fetch details
      end

      self.confirmed[username] == true # table lookup for user 'username'
    end


    # Returns the partner of this user in this partnership.
    def partner_of(user)
      partner = self.first_user.username == user.username ? self.second_user : self.first_user
    end


    # Returns true if this partnership is active. Otherwise it returns false.
    def active?
      self.confirmed_by_first_user and self.confirmed_by_second_user
    end

    def users
      self.class.extract_user_names_from_uri(self.uri)
    end


    # open eigenclass
    class << self

      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash'
        end

        properties = {
            uri: params['uri'],
            id: params['id'],
            public_visible: params['publicvisible']
        }

        # check if user properties are present
        if not params['user1'].nil? and not params['user2'].nil?
          # this hack is dedicated to my dear friend julian pollack.
          # awesome guy. i have learned a lot from him...
          # create a boolean lookup table to avoid error prone 'if comparisons' with usernames
          # use username as key values
          confirmed = {
              params['user1']['username'] => (params['userconfirmed1']=='true'),
              params['user2']['username'] => (params['userconfirmed2']=='true')
          }

          properties = properties.merge({
                                            first_user: User.create(params['user1']),
                                            second_user: User.create(params['user2']),
                                            confirmed: confirmed,
                                            confirmed_by_first_user: (params['userconfirmed1']=='true'),
                                            confirmed_by_second_user: (params['userconfirmed2']=='true')
                                       })
        else # if not extract user names from the uri
          first_user, second_user  = self.extract_user_names_from_uri(params['uri'])
          properties = properties.merge({
                                            first_user: User.create('username' => first_user),
                                            second_user: User.create('username' => second_user)
                                        })
        end

        new(properties)
      end


      def serialize(partnership)
        if not partnership.kind_of?(Partnership)
          raise ArgumentError, 'Argument must be of type partnership'
        end
        hash = {
            publicvisible: partnership.public_visible
        }
        hash.to_xml(root: 'partnership')
      end


      # Returns a list containing two user names.
      def extract_user_names_from_uri(uri)
        resource = uri.split('/').last # get last part of the uri
        resource = resource[0...-1] if resource[-1] == '/' # remove last forward slash if present
        resource.split(';')
      end

    end # end of eigenclass

  end # end of class Partnership


  # This class is responsible for adapting the resource sport..
  class Sport < BaseResource

    # getters and setters
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
