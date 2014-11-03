module RestAdapter
  module Proxy

    class InvalidAuth < Proxy::BaseAuth

      def initialize(params={})

      end

      def authorized?
        false
      end


      def save(params={})
        false
      end

      def update(params={})
        false
      end

      def delete(params={})
        false
      end

      def username
        'null user'
      end

      def http_auth_header
        {}
      end

    end

  end
end