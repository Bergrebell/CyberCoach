module RestAdapter

  module Behaviours

    module AutoConstructor

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def initialize(params={})
          props = Hash[params.map {|k,v| [k.to_sym,v]}]
          props.each do |key,value|
            instance_variable_set("@#{key}",value)
          end
        end

      end

    end

  end

end