module RestAdapter

  module Proxy

    class RailsAuth < Proxy::BaseAuth


      def initialize(params)
        @rails_user_id = params[:user_id]
        @valid = true # be optimistic hehehe
        @username = nil
        @password = nil
      end

      def username
        get_credentials
        @username
      end

      def http_auth_header
        get_http_auth_header
      end

      def save(object)
        return if @valid == false

        object.save(get_http_auth_header)
      end


      def update(object)
        return if @valid == false

        object.update(get_http_auth_header)
      end


      def delete(object)
        return if @valid == false

        object.delete(get_http_auth_header)
      end


      def authorized?
        get_credentials
        @valid and (Models::User.authenticate(username: @username, password: @password)) != false
      end

      private

      def get_http_auth_header
        get_credentials
        { authorization: RestAdapter::Helper.basic_auth_encryption(username: @username, password: @password) }
      end


      def get_credentials
        if @username.nil? or @password.nil?
          user = ::User.find_by id: @rails_user_id
          if user
            @password = user.password
            @username = user.name
            @valid = true
          else
            @valid = false
          end
        end
      end

    end

  end

end