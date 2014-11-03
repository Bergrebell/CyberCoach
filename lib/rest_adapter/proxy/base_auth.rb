module RestAdapter

  module Proxy

    class BaseAuth

      def authorized?
        raise 'Not implemented!'
      end

      def save(params={})
        raise 'Not implemented!'
      end


      def update(params={})
        raise 'Not implemented!'
      end


      def delete(params={})
        raise 'Not implemented!'
      end

    end

  end

end