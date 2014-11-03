module Facade

  class Partnership < Facade::BaseFacade

    attr_accessor :auth_proxy, :partnership

    def initialize(params)
      @auth_proxy = params[:auth_proxy]
      @partnership = params[:partnership]
    end

    def id
      @partnership.id
    end

    def rails_model
      @partnership
    end

    def cc_model
      @partnership
    end

    def auth_proxy
      @auth_proxy
    end

    # factory method
    def self.create(params)
      auth_proxy = get_auth_proxy params
      params[:first_user] = params[:first_user].cc_model  if params[:first_user].is_a?(Facade::BaseFacade)
      params[:second_user] = params[:second_user].cc_model  if params[:second_user].is_a?(Facade::BaseFacade)
      partnership = RestAdapter::Models::Partnership.new params

      self.new auth_proxy: auth_proxy, partnership: partnership
    end


    def self.retrieve(params)
      auth_proxy = get_auth_proxy params
      auth_header = {authorization: auth_proxy.auth_header}
      partnership = RestAdapter::Models::Partnership.retrieve(params, auth_header)

      self.new auth_proxy: auth_proxy, partnership: partnership
    end


    def save(params={})
      if @auth_proxy.save(@partnership)
        ObjectStore::Store.remove([@auth_proxy.username,:detailed_partnerships])
      else
        false
      end
    end


    def delete(params={})
      if @auth_proxy.delete(@partnership)
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
