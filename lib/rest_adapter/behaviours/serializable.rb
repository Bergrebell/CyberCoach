module RestAdapter

  module Behaviours

    module Serializable

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend(ClassMethods)

        # Required class methods (preconditions) which must be implemented for using this behaviour.
        raise 'Object#as_hash() is not implemented! Precondition is not satisfied.' if not base.method_defined? :as_hash

      end

      module ClassMethods

        def serialize_properties(*properties)
          @serializable_properties = properties
        end

        def serializable_properties
          @serializable_properties.nil? ? [] : @serializable_properties
        end

        def serialize_if(params)
          @serialize_ifs = Hash.new if @serialize_ifs.nil?
          params.each do |key,validator|
            @serialize_ifs[key] = validator if validator.is_a?(Proc)
            @serialize_ifs[key] = ->(property) { self.send(validator, property) } if validator.is_a?(Symbol)
          end
        end

        def serialize_ifs
          @serialize_ifs.nil? ? Hash.new : @serialize_ifs
        end

      end


      module InstanceMethods

        def serialize
          filtered_properties = Hash.new
          properties = self.as_hash
          self.class.serializable_properties.each do |key|
            string_key = key.to_s
            mapped_key = string_key.tr('_', '') # automatically map public_visible to publicvisible
            property = properties[string_key]
            if_true = self.class.serialize_ifs[key].nil? ? ->(x) { true } : self.class.serialize_ifs[key]
            #automatically map a property to a string
            filtered_properties = filtered_properties.merge({mapped_key => property.to_s}) if if_true.call(property)
          end
          filtered_properties.to_xml(root: self.class.resource_name)
        end

      end

    end

  end

end