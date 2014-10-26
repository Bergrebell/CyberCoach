module RestAdapter

  # This class implements common instance and class methods
  # that all resources have in common.
  class BaseResource < Resource

    include RestAdapter::Behaviours::AutoConstructor
    include RestAdapter::Behaviours::LazyLoading
    include RestAdapter::Behaviours::DependencyInjector

    include RestAdapter::Behaviours::AsHash
    include RestAdapter::Behaviours::Serializable
    include RestAdapter::Behaviours::Deserializable

    include RestAdapter::Config::CyberCoach # must be included as last
    include RestAdapter::Behaviours::ActiveRecord
    include RestAdapter::Behaviours::Validator



    # class methods for the user resource
    # open eigenclass
    class << self

      def available
        @available
      end

    end # end of eigenclass

  end # end of class BaseResource
end