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

      deserialize_properties :uri, :username, :password, :email, :partnerships, :subscriptions,
                             :publicvisible => :public_visible, :realname => :real_name,
                             :datecreated => :date_created

      serialize_properties :password, :email, :real_name, :public_visible

      attr_accessor :username, :password, :email, :real_name, :public_visible, :partnerships, :subscriptions, :date_created

      lazy_loading_on :email, :real_name, :public_visible, :partnerships, :subscriptions

      serialize_if :password => :password_validator, :username => :username_validator,
                   :real_name => :real_name_validator, :public_visible => :public_validator,
                   :email => :email_validator

      inject :partnerships => RestAdapter::Models::Partnership, :subscriptions => RestAdapter::Models::Subscription,
             :date_created => RestAdapter::Helper::DateTimeInjector

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


      def fetch_partnerships
        @partnerships = self.partnerships.map { |p| p.fetch }
      end


      # open eigenclass
      class << self

        # This class method authenticates a user against the CyberCoach webservice.
        # Returns a RestAdapter::Models::User user object if authentication succeeds otherwise false.
        #
        # ==== Attributes
        # The params hash accepts the following properties:
        #
        # * +username+        - username
        # * +password+        - password
        #
        # ==== Example
        # RestAdapter::Models::User.authenticate username: 'alex', password: 'test'
        #   => RestAdapter::Models::User
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
        # with at least one letter. Otherwise it returns true.
        #
        def username_available?(username)
          # check if username is alphanumeric and that it contains at least four letters
          if  not /^[a-zA-Z0-9]{1,}$/ =~ username
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