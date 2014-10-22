module RestAdapter

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


    # Returns true if this user is befriended with the given 'another_user'.
    def befriended_with?(another_user)
      not self.partnerships.select {|p| p.associated_with?(another_user)}.empty?
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
            public_visible: params['publicvisible']
        }

        if not params['partnerships'].nil?
          partnerships =  params['partnerships'].map {|p| module_name::Partnership.create p }
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
              content_type: self.serialize_format,
              accept: self.deserialize_format,
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
          uri = self.create_absolute_resource_uri(username)
          response = RestClient.get(uri, {
              content_type: self.deserialize_format,
              accept: self.deserialize_format
          })
          false
        rescue
          true
        end
      end

    end  # end of eigenclass

  end # end of class User
end