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
            if instance_variable_get("@#{property}").is_a?(Hash)
              object = clazz.call(instance_variable_get("@#{property}"))
              instance_variable_set("@#{property}",object)
            elsif instance_variable_get("@#{property}").is_a?(Array)
              objects = Array.new
              instance_variable_get("@#{property}").each do |v|
                (objects << clazz.call(v)) if v.is_a?(Hash)
              end
              instance_variable_set("@#{property}",objects) if not objects.empty?
            end
          end
        end

      end


      module ClassMethods

        def inject(dependencies)
          @dependencies = Hash[dependencies.map {|key,clazz| [key, !clazz.is_a?(Proc) ? ->(x) {clazz.create(x)} : clazz] }]
        end

        def dependencies
          @dependencies.nil? ? Array.new : @dependencies
        end

      end

    end

  end

end