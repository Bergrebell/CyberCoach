module RestAdapter
  module Proxy
    # This class is responsible for providing access for authentication protected operations.
    # An operation like save, update or delete applied on a object needs authentication.
    # To hide the details and to provide a common interface you can use a AuthProxy object.

    class Auth < Proxy::BaseAuth


      # Creates AuthProxy object.
      # It takes as argument a hash with the following properties:
      # { :username => a username,
      #   :password => a password }
      #
      #
      def initialize(params)
        # garbage in, garbage out
        @invalid = params[:username].nil? or params[:password].nil? ? true : false
        @username = params[:username]
        @password = params[:password]
        @http_auth_header = {authorization: Helper.basic_auth_encryption(username: @username, password: @password)}
      end


      def http_auth_header
        @http_auth_header
      end


      def username
        @username
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
      def save(object)
        return false if @invalid

        object.save(@http_auth_header)
      end

      # Applies the delete operation on the object if provided, otherwise on the subject.
      #
      # Examples====
      # auth_proxy.delete(user)
      #
      def delete(object)
        return false if @invalid

        object.delete(@http_auth_header)
      end


      def update(object)
        return false if @invalid

        object.update(@http_auth_header)
      end

    end

  end
end