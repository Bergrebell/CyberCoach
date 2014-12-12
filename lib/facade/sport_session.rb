module Facade

  # Facade classes

  class SportSession

    DATETIME_FORMAT = '%Y-%m-%d' # example: 2014-01-01

    include Facade::Wrapper

    # Delegate all calls to the rails SportSession model and encapsulate the result.
    def self.method_missing(meth, *args, &block)
      # catch all calls and encapsulate them in a block
      query do
        ::SportSession.send(meth, *args, &block)
      end
    end


    def self.wrap(rails_object)
      rails_object
    end


    def self.create(params={})
      user_id = params[:user].id
      params.delete(:user)
      params[:user_id] = user_id
      ::SportSession.new(params)
    end

    class Running < SportSession

      def self.create(params={})
        user_id = params[:user].id
        params.delete(:user)
        params[:user_id] = user_id
        ::Running.new(params)
      end

    end

    class Boxing < SportSession

      def self.create(params={})
        user_id = params[:user].id
        params.delete(:user)
        params[:user_id] = user_id
        ::Boxing.new(params)
      end

    end

    class Cycling < SportSession

      def self.create(params={})
        user_id = params[:user].id
        params.delete(:user)
        params[:user_id] = user_id
        ::Cycling.new(params)
      end

    end

    class Soccer < SportSession

      def self.create(params={})
        user_id = params[:user].id
        params.delete(:user)
        params[:user_id] = user_id
        ::Soccer.new(params)
      end

    end

  end




end

