module Facade

  module RailsModel

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def rails_object
        raise 'Not implemented!'
      end

      # For rails compatibility such that action pack can be used.
      # See for more details: http://apidock.com/rails/ActiveRecord/Base/to_param
      def to_param
        rails_object.to_param
      end


      # for rails compatibility: called by rails form helpers to choose the right http method
      def new_record?
        rails_object.new_record? rescue true
      end


      # for rails compatibility: called by rails form helpers to choose the right http method
      def persisted?
        rails_object.persisted? rescue false
      end


      def errors
        rails_object.errors
      end


      def valid?
        rails_object.valid?
      end


    end

  end

end