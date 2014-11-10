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

    def self.facade_for_1
      raise 'Not implemented!'
    end

    def self.facade_for_2
      raise 'Not implemented!'
    end


    def self.wrap(hide_object_behind_facade)
      raise 'Not implemented!'
    end


    # For rails compatibility such that action pack can be used.
    # See for more details: http://apidock.com/rails/ActiveRecord/Base/to_param
    def to_param
      rails_model.to_param
    end


    # map where, find etc from rails....good luck...it might bite you!!!!!
    def self.find_by(*args, &block)
      result = self.facade_for_2.send :find_by, *args, &block
      wrap(result)
    end


    def self.where(*args, &block)
      result = self.facade_for_2.send :where, *args, &block
      case result
        when ::ActiveRecord::Relation
          result.map {|r| wrap(r) }.select {|r| !r.nil? }
        else
          wrap(result)
      end
    end


    def self.method_missing(method, *args, &block)
      begin
        facade_for_1.send method, *args, &block
      rescue
        facade_for_2.send method, *args, &block if not facade_for_2.nil?
      end
    end


    def method_missing(method, *args, &block)
      begin
        cc_model.send method, *args, &block
      rescue
        rails_model.send method, *args, &block
      end
    end


    def clean_up

    end


  end

end