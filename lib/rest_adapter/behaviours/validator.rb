module RestAdapter

  module Behaviours

    module Validator

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end


      module InstanceMethods

        def valid?
          booleans = self.class.validators.map {|property,validator| validate(property) }
          booleans.reduce {|acc,result| acc &&= result }
        end

        def validate(property)
          variable_name = "@#{property}".to_sym
          validator = self.class.validators[property]
          !validator.nil? ? validator.call(instance_variable_get(variable_name)) : false
        end
      end


      module ClassMethods

        def present?(value)
          not value.nil?
        end

        def validates(params)
          @validators = Hash.new if @validators.nil?
          params.each do |key,validator|
            @validators[key] = validator if validator.is_a?(Proc)
            @validators[key] = ->(property) { self.send(validator, property) } if validator.is_a?(Symbol)
          end
        end

        def validators
          @validators.nil? ? Hash.new : @validators
        end
      end

    end


  end

end