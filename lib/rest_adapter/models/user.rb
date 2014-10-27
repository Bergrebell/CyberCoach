module RestAdapter

  module Models

    # This class is responsible for adapting the resource user.
    class User < BaseResource
      include RestAdapter::Behaviours::LazyLoading
      include RestAdapter::Behaviours::DependencyInjector

      # set user resource specific config values
      set_id :username
      set_resource_path '/users'
      set_resource 'user'

      deserialize_properties :uri, :username, :password, :email, :partnerships,
                             :publicvisible => :public_visible, :realname => :real_name

      serialize_properties :password, :email, :real_name, :public_visible

      attr_accessor :username, :password, :email, :real_name, :public_visible, :partnerships

      lazy_loading_on :email, :real_name, :public_visible, :partnerships

      serialize_if :password => :password_validator, :username => :username_validator,
                   :real_name => :real_name_validator, :public_visible => :public_validator,
                   :email => :email_validator

      inject :partnerships => Partnership

      after_deserialize do |params|
        properties = {'password' => nil}
        #if not params['partnerships'].nil?
        #  partnerships = params['partnerships'].map { |p| module_name::Partnership.create p }
        #  properties = properties.merge({'partnerships' => partnerships})
        #end
        properties
      end


      def self.password_validator(password)
        not password.nil? and password.length >= 4
      end

      def self.username_validator(username)
        not username.nil? and username.length >= 4
      end

      def self.public_validator(num)
        begin # sorry ruby, but constants are just pain in the ass...
          RestAdapter::Privacy.constants.map { |key| RestAdapter::Privacy.const_get(key) }.include?(num)
        rescue
          false
        end
      end

      def self.real_name_validator(name)
        not name.nil? and name.length >= 4
      end

      def self.email_validator(email)
        not email.nil? and email.length >= 4
      end


      # Returns all friends of this user.
      def friends
        partnerships = self.partnerships.map do |p|
          if p.is_a?(Hash) # stupid hack
            RestAdapter::Partnership.create(p).fetch
          else
            p.fetch
          end
        end # fetch all details
        active_partnerships = partnerships.select { |p| p.active? } # filter, only get active partnerships
        friends = active_partnerships.map { |p| p.partner_of(self) } # get users instead of partnerships
      end


      # Returns all received friend requests of this user.
      def received_friend_requests
        partnerships = self.partnerships.map do |p|
          if p.is_a?(Hash) # stupid hack
            RestAdapter::Partnership.create(p).fetch
          else
            p.fetch
          end
        end # fetch all details
        proposed_partnerships = partnerships.select { |p| not p.confirmed_by?(self) } # filter, only get proposed partnerships
        friends = proposed_partnerships.map { |p| p.partner_of(self) } # get users instead of partnerships
      end


      # Returns all sent friend requests of this user.
      def sent_friend_requests
        partnerships = self.partnerships.map do |p|
          if p.is_a?(Hash) # stupid hack
            RestAdapter::Partnership.create(p).fetch
          else
            p.fetch
          end
        end # fetch all details
        proposed_partnerships = partnerships.select { |p| p.confirmed_by?(self) and not p.active? }
        friends = proposed_partnerships.map { |p| p.partner_of(self) } # get users instead of partnerships
      end


      # Returns true if this user is befriended with the given 'another_user'.
      def befriended_with?(another_user)
        not self.partnerships.select { |p|
          if p.is_a?(Hash) # stupid hack
            RestAdapter::Partnership.create(p).associated_with?(another_user)
          else
            p.associated_with?(another_user)
          end
        }.empty?
      end

      def not_befriended_with?(another_user)
        !befriended_with?(another_user)
      end


      # open eigenclass
      class << self

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

      end # end of eigenclass

    end # end of class User
  end
end