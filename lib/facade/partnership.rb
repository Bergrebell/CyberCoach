module Facade

  class Partnership < Facade::BaseFacade

    attr_accessor :auth_proxy, :partnership

    def initialize(params)
      @auth_proxy = params[:auth_proxy]
      @partnership = params[:partnership]
    end

    def self.facade_for_1
      RestAdapter::Models::Partnership
    end

    def self.facade_for_2
      nil
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
      raise 'not a facade object' if not params[:confirmer].is_a?(Facade::BaseFacade)
      raise 'not a facade object' if not params[:proposer].is_a?(Facade::BaseFacade)
      auth_proxy = params[:proposer].auth_proxy
      partnership_hash = params.dup
      partnership_hash = partnership_hash.merge({
          first_user: params[:proposer].cc_model,
          second_user: params[:confirmer].cc_model,
          public_visible: RestAdapter::Privacy::Public})
      partnership = RestAdapter::Models::Partnership.new partnership_hash
      self.new auth_proxy: auth_proxy, partnership: partnership
    end


    def self.retrieve(params)
      auth_proxy = params[:confirmer].auth_proxy
      auth_header = auth_proxy.http_auth_header
      retrieve_params = { first_user: params[:confirmer], second_user: params[:proposer] }
      partnership = RestAdapter::Models::Partnership.retrieve(retrieve_params, auth_header)

      self.new auth_proxy: auth_proxy, partnership: partnership
    end


    def save(params={})
      if @auth_proxy.save(@partnership)
        ObjectStore::Store.remove([@auth_proxy.username,:detailed_partnerships])
        true
      else
        false
      end
    end


    def delete(params={})
      if @auth_proxy.delete(@partnership)
        ObjectStore::Store.remove([@auth_proxy.username, :detailed_partnerships])
        true
      else
        false
      end
    end

  end

end
