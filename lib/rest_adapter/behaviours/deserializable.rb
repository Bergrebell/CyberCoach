module RestAdapter

  module Behaviours

    module Deserializable

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def deserialize_properties(*properties)
          @deserializable_properties = properties
        end

        def deserializable_properties
          @deserializable_properties.nil? ? [] : @deserializable_properties
        end


        # This class method deserializes the received response of a rest client
        # and delegates the object creation to its subclasses.
        def deserialize(response)
          hash = JSON.parse(response)
          if not hash[self.resource_name_plural].nil? # check if it's a list of resources
            @available = hash['available'].to_i
            @start = hash['start'].to_i
            @end = hash['end'].to_i
            resources = hash[self.resource_name_plural]
            objs = resources.map do |resource|
              self.create resource # call template method 'create'
            end
          else # otherwise it is a single resource
            obj = self.create hash # call template method 'create'
          end
        end


        # Creates an object of this resource.
        def create(params)
          hash = Hash.new
          deserializable_properties.each do |key|
            if key.is_a?(Hash)
              key.each do |mapped_key, property_key|
                mapped_string_key = mapped_key.to_s
                hash = hash.merge({property_key => params[mapped_string_key]})
              end
            else
              mapped_string_key = key.to_s.tr('_', '')
              hash = hash.merge({key => params[mapped_string_key]})
            end
          end

          sub_hash = after_deserializer.call(params)
          hash = hash.merge(sub_hash) if not sub_hash.nil?

          self.new hash # create object
        end


        def after_deserialize(&mapper)
          @mapper = mapper
        end

        def after_deserializer
          @mapper.nil? ? ->(x) { nil } : @mapper
        end

      end


    end

  end

end