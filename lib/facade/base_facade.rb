module Facade

  class BaseFacade

    # Returns the rails model that is associated with this object.
    def rails_model
      raise 'Not implemented!'
    end

    def rails_class
      raise 'Not implemented!'
    end

    # Returns the cyber coach model that is associated with this object.
    def cc_model
      raise 'Not implemented!'
    end

    def cc_class
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


    def self.wrap(hide_object_behind_facade)
      raise 'Not implemented!'
    end


    # For rails compatibility such that action pack can be used.
    # See for more details: http://apidock.com/rails/ActiveRecord/Base/to_param
    def to_param
      rails_model.to_param
    end


    # Integrates the gem WillPaginate into the BaseFacade
    def self.paginate(options)
      page = options[:page] || 1 # use page = 1 as default
      per_page = options[:per_page] || self.rails_class.per_page # use per_page defined in the models as default
      # this is the only way I was able to hack WillPaginate into the Facade::BaseFacade
      WillPaginate::Collection.create(page,per_page) do |pager|
        result,count =  if block_given?
                          query = yield
                          count = query.count
                          res = query.offset(pager.offset).limit(pager.per_page)
                          [res,count]
                        else
                          count = rails_class.count
                          res = rails_class.offset(pager.offset).limit(pager.per_page)
                          [res,count]
                        end
        result = result.map { |object| wrap(object)}
        pager.replace(result)
        pager.total_entries = count
      end
    end


    #
    # Wraps a rails query like all, select, where, find, find_by etc.
    # The result of the query is wrapped into facade objects.
    #
    # ====Examples
    #
    # Facade::SportSession.query do
    #   SportSession.all # get all sport sessions that are saved in the rails database
    # end
    #
    #
    # Facade::SportSession.query do
    #   SportSession.where(type: 'Running').where(user_id: 2)
    # end
    #
    #
    # Facade::User.query do
    #  User.find_by id: 2
    # end
    #
    #
    def self.query
      result = yield
      case result
        when ::ActiveRecord::Relation
          result.map {|r| wrap(r) }.select {|r| !r.nil? }
        else
          wrap(result)
      end
    end


    # map where, find etc from rails....good luck...it might bite you!!!!!
    def self.find_by(*args, &block)
      result = self.rails_class.send :find_by, *args, &block
      wrap(result)
    end


    def self.where(*args, &block)
      result = self.rails_class.send :where, *args, &block
      case result
        when ::ActiveRecord::Relation
          result.map {|r| wrap(r) }.select {|r| !r.nil? }
        else
          wrap(result)
      end
    end


    def self.method_missing(method, *args, &block)
      begin
        cc_class.send method, *args, &block
      rescue #TODO: implement a proper error handling if rails_class is nil
        rails_class.send method, *args, &block if not rails_class.nil?
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