module Facade

  module Wrapper

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods


      def query(&block)
        result = block.call
        case result
          when ::ActiveRecord::Relation
            result.map {|r| wrap(r) }.select {|r| !r.nil? }
          when Array
            result.map {|r| wrap(r) }.select {|r| !r.nil? }
          else
            wrap(result)
        end
      end


      def wrap(a_object)
        raise 'Not implemented!'
      end

    end


  end

end