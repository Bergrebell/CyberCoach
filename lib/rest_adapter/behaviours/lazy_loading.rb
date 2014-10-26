module RestAdapter

  module Behaviours

    module LazyLoading

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end


      module InstanceMethods

        def initialize(params)
          super(params)
          create_lazy_loading_getters
        end

        # Creates lazy loading getters for properties that are configured as lazy properties.
        def create_lazy_loading_getters
          self.class.lazy_loading_properties.each do |property|
            define_singleton_method(property) do
              if  instance_variable_get("@#{property}").nil?
                self.fetch!
              end
              if instance_variable_get("@#{property}").nil? and property[-1] == 's' # hack alert
                []
              else
                instance_variable_get("@#{property}")
              end
            end
          end
        end

      end


      module ClassMethods
        # This class method defines on which properties lazy loading will be applied.
        # Lazy loading on a property will automatically fetch the missing property.
        #
        def lazy_loading_on(*properties)
          @lazy_loading_properties = properties
        end

        # Returns a list of properties where lazy loading is applied.
        #
        def lazy_loading_properties
          @lazy_loading_properties.nil? ? Array.new : @lazy_loading_properties
        end

      end

    end

  end

end