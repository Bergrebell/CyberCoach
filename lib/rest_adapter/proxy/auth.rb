module RestAdapter
  module Proxy
    # This class is responsible for providing access for authentication protected operations.
    # An operation like save, update or delete applied on a object needs authentication.
    # To hide the details and to provide a common interface you can use a AuthProxy object.

    class Auth < Proxy::BaseAuth

      attr_reader :auth_header
      attr_reader :http_auth_header

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
        # garbage in, garbage out
        @invalid = params[:username].nil? or params[:password].nil? ? true : false
        @username = params[:username]
        @password = params[:password]
        @real_subject = params[:subject]
        @auth_header = Helper.basic_auth_encryption(username: @username, password: @password)
        @http_auth_header = {authorization: @auth_header}
      end

      # Checks if this AuthProxy object is valid in terms of the user credentials.
      # For validation an authentication request is performed.
      # Only for testing purposes!
      def authorized?
        return false if @invalid
        (Models::User.authenticate(username: @username, password: @password)) != false
      end


      # Applies the save operation on the object if provided, otherwise on the subject.
      #
      # Examples====
      # user.email = 'blahaha'
      # auth_proxy.save(user)
      #
      def save(object=nil)
        return false if @invalid

        if not object.nil? #if object is nil, apply the op on the subject.
          object.save(@http_auth_header)
        elsif not @real_subject.nil?
          @real_subject.save(@http_auth_header)
        else
          raise 'AuthProxy does nothing'
        end
      end


      def update(object=nil)
        return false if @invalid

        if not object.nil? #if object is nil, apply the op on the subject.
          object.save(@http_auth_header)
        elsif not @real_subject.nil?
          @real_subject.save(@http_auth_header)
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
        return false if @invalid

        if not object.nil? #if object is nil, apply the op on the subject.
          object.delete(@http_auth_header)
        elsif not @real_subject.nil?
          @real_subject.delete(@http_auth_header)
        else
          raise 'AuthProxy does nothing'
        end
      end


      # make a alias for method save
      alias_method :update, :save

      def retrieve(params)
        @real_subject.retrieve(params,@http_auth_header)
      end


      def all(params)
        @real_subject.all(params,@http_auth_header)
      end


      def subject(object)
        @real_subject = object
        self
      end

      # Delegates each method call that is not supported by this proxy
      # to the subject.
      def method_missing(name, *args, &block)
        # This is basically used for wrapping a user object.
        # The only simple way to get the user credentials without dirty hacking
        # is in the authenticate class method in the User class.
        # Instead of returning a User object the authenticate class method returns a AuthProxy object
        # which acts like user object.
        # So here the user object plays the role of the subject.

        @real_subject.send(name, *args, &block)
      end

    end


  end
end