module RestAdapter

  # This class is responsible for adapting the resource sport..
  class Sport < BaseResource

    # getters and setters
    attr_reader :name, :id
    set_resource_path '/sports'
    set_resource 'sport'


    def initialize(params)
      @name = params[:name]
      @id = params[:id]
      @uri = params[:uri]
    end


    # open eigenclass
    class << self

      def create(params)
        new({
                name: params['name'],
                id: params['id'],
                uri: params['uri']
            })
      end

    end # end of eigenclass

  end # end of class Sport
end