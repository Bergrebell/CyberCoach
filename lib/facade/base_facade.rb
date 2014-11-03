module Facade

  class BaseFacade

    # Returns the rails model that is associated with this object.
    def rails_model
      raise 'Not implemented!'
    end

    # Returns the cyber coach model that is associated with this object.
    def cc_model
      raise 'Not implemented!'
    end

    # Returns always the id of the rails model.
    def id
      raise 'Not implemented!'
    end


    # Each facade class must provide a factory create method!.
    def self.create(params={})
      raise 'Not implemented!'
    end


    # Returns the auth proxy object that is associated with this object,
    def auth_proxy
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