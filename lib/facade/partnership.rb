module Facade

  class Partnership < Facade::BaseFacade

    attr_accessor :auth_proxy, :partnership

    def initialize(params=nil)
      @auth_proxy = self.class.get_auth_proxy params if not params.nil?
      @partnership = RestAdapter::Models::Partnership.new params if not params.nil?
    end



    def self.retrieve(params)
      partnership = RestAdapter::Models::Partnership.new params
      partnership.fetch!
      p = self.new
      p.partnership = partnership
      p.auth_proxy = get_auth_proxy params
      p
    end

    def save
      if @auth_proxy.save(@partnership)
        ObjectStore::Store.remove([@auth_proxy.username,:detailed_partnerships])
      else
        false
      end
    end


    def delete
      if @auth_proxy.save(@partnership)
        ObjectStore::Store.remove([@auth_proxy.username, :detailed_partnerships])
      else
        false
      end
    end

    def self.method_missing(method, *args, &block)
      RestAdapter::Models::Partnership.send method, *args, &block
    end

    def method_missing(method, *args, &block)
      @partnership.send method, *args, &block
    end


    private
    def self.get_auth_proxy(params)
      if params[:first_user].is_a?(Facade::BaseFacade)
        params[:first_user].auth_proxy
      elsif params[:second_user].is_a?(Facade::BaseFacade)
        params[:second_user].auth_proxy
      else
        raise Error, 'None of the provided user is a facade user!'
      end
    end
  end

end
