module RestAdapter

  module Behaviours

    module DependencyInjector

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def initialize(params)
          super(params)
          inject_dependencies
        end

        def inject_dependencies
          self.class.dependencies.each do |property,clazz|
            variable_symbol = "@#{property}"
            variable_value = instance_variable_get(variable_symbol)

            case variable_value
              when Array
                objects = Array.new
                instance_variable_get(variable_symbol).each do |v|
                  (objects << clazz.call(v)) if v.is_a?(Hash)
                end
                instance_variable_set(variable_symbol,objects) if not objects.empty?
              when Hash,Numeric,String
                object = clazz.call(variable_value)
                instance_variable_set(variable_symbol,object)
            end

          end
        end

      end


      module ClassMethods

        def inject(dependencies)
          mapped_injectors = dependencies.map do |key, injector|
            injector_fun = case injector
                         when Symbol
                           ->(x) { self.send injector, x } # class method
                         when Proc
                           injector # closure
                         when Class
                           ->(x) { injector.create(x) }
                         else
                           raise 'Injector must be a class method, a proc or a class with class method create()'
                       end

            [key, injector_fun]
          end
          @dependencies = Hash[mapped_injectors]
        end


        def dependencies
          @dependencies.nil? ? Array.new : @dependencies
        end


      end

    end

  end

end