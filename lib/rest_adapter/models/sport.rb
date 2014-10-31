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

      module Type
        Running = RestAdapter::Models::Sport.new name: 'Running'
        Boxing = RestAdapter::Models::Sport.new name: 'Boxing'
        Soccer = RestAdapter::Models::Sport.new name: 'Soccer'
        Cycling = RestAdapter::Models::Sport.new name: 'Cycling'
      end

      Types = [Type::Running,Type::Boxing,Type::Soccer,Type::Cycling]

    end # end of class Sport
  end
end