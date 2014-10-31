module RestAdapter

  module Models

    # This class implements common instance and class methods
    # that all resources have in common.
    class BaseResource < Resource

      include RestAdapter::Config::CyberCoach
      include RestAdapter::Behaviours::AutoConstructor
      include RestAdapter::Behaviours::AsHash
      include RestAdapter::Behaviours::Serializable
      include RestAdapter::Behaviours::Deserializable
      include RestAdapter::Behaviours::ActiveRecord


      # class methods for the user resource
      # open eigenclass
      class << self

        def available
          @available
        end

      end # end of eigenclass

    end # end of class BaseResource
  end
end