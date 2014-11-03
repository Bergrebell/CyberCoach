module RestAdapter

  module Proxy

    class BaseAuth

      def authorized?
        raise 'Not implemented!'
      end

      def save(params=nil)
        raise 'Not implemented!'
      end


      def update(params=nil)
        raise 'Not implemented!'
      end


      def delete(params=nil)
        raise 'Not implemented!'
      end

      def username
        raise 'Not implemented!'
      end


      def http_auth_header
        raise 'Not implemented!'
      end

    end

  end

end