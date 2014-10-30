module RestAdapter

  module Models
    # This class is responsible for adapting the resource sport..
    class Sport < BaseResource
      include RestAdapter::Behaviours::LazyLoading

      set_id :name
      set_resource_path '/sports'
      set_resource 'sport'
      deserialize_properties  :uri, :name, :description, :id => :cc_id
      attr_accessor :name, :description, :cc_id
      lazy_loading_on :description

    end # end of class Sport
  end
end