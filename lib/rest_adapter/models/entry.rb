module RestAdapter

  module Models

    class Entry < BaseResource
      include RestAdapter::Behaviours::DependencyInjector

      set_resource_path users: '/users', partnerships: '/partnerships'

      attr_accessor :cc_id, :uri, :type, :comment, :public_visible, :date_created, :date_modified,
                    :entry_location, :entry_date, :entry_duration, :subscription,
                    :course_length, :course_type, :bicycle_type, :round_duration, :number_of_rounds


      deserialize_properties :uri, :type, :comment, :track, :subscription,
                             :id => :cc_id,
                             :publicvisible => :public_visible, # map properties names: e.g :publicvisible to :public_visible
                             :datecreated => :date_created,
                             :datemodified => :date_modified,
                             :entrylocation => :entry_location,
                             :entrydate => :entry_date,
                             :entryduration => :entry_duration,
                             :courselength => :course_length,
                             :coursetype => :course_type,
                             :bicycletype => :bicycle_type,
                             :round_duration => :round_duration,
                             :numberofrounds => :number_of_rounds

      serialize_properties :comment, :track, :entry_date, :entry_location, :entry_duration, :public_visible,
                           :round_duration, :number_of_rounds, :course_type, :course_length, :bicycle_type


      inject :subscription => RestAdapter::Models::Subscription, :track => RestAdapter::Models::TrackProperty,
             :entry_date => RestAdapter::Helper::DateTimeInjector,
             :date_created => RestAdapter::Helper::DateTimeInjector,
             :date_modified => RestAdapter::Helper::DateTimeInjector

      module Type
        Running = 'entryrunning'
        Cycling = 'entrycycling'
        Boxing = 'entryboxing'
        Soccer = 'entrysoccer'
      end

      TypeLookup = {
          'Running' => Type::Running,
          'Boxing' => Type::Boxing,
          'Cycling' => Type::Cycling,
          'Soccer' => Type::Soccer,
          'running' => Type::Running,
          'boxing' => Type::Boxing,
          'cycling' => Type::Cycling,
          'soccer' => Type::Soccer
      }


      def initialize(params={})
        super(params)
      end

      # This method overrides 'id' from the base resource class.
      def id
        if @id.nil? #if id is not available try to build one using the properties
          # find out if the subscription is associated with a user or a partnership
          subscription.id
        else
          @id
        end
      end


      # This method overrides 'uri' from the base resource class.
      def uri
        if @uri.nil? #if uri is not available try to build one using the properties
          subscription.uri
        else
          @uri
        end
      end


      # This method overrides 'create_absolute_uri' from the base resource class.
      def create_absolute_uri
        self.class.base + self.uri
      end


      def serialize
        hash = Hash.new
        self.class.serializable_properties.each do |property|
          # serialize only properties that are not nil
          hash[property.to_s.tr('_','')] = (self.send property).to_s if not (self.send property).nil?
        end
        hash.to_xml(root: self.type)
      end


      def save(params={})
        method = self.cc_id.nil? ? :post : :put

        response_handler = proc do |response, request, result|
          return response.headers[:location]
        end

        params = params.merge({method: method, deserialize: false, response_handler: response_handler})
        super(params)
      end


      def track=(data)
        @track = RestAdapter::Models::TrackProperty.new data
      end

      def track
        @track
      end

      class << self

        def retrieve(params)
          resource_id = if params.is_a?(Hash)
            id = params[:id]
            user_partnership_id = parse_retrieve_params(params)
            "#{user_partnership_id}/#{id}"
          else
            params
          end
          super(resource_id)
        end


        # This class method overrides 'create_absolute_resource_uri' from the base resource class.
        def create_absolute_resource_uri(resource_path_id)
          base + site + resource_path_id
        end


        def parse_retrieve_params(params)
          if params.is_a?(Hash) # check if hash
            if not params[:sport].nil?
              sport = params[:sport].is_a?(String) ? params[:sport] : params[:sport].id
              path_key, user_partnership_id = if not params[:partnership].nil?
                                                partnership_id = if params[:partnership].is_a?(String)
                                                                   params[:partnership]
                                                                 else
                                                                   params[:partnership].id
                                                                 end
                                                [:partnerships, partnership_id]
                                              elsif not params[:user].nil?
                                                user_id = if params[:user].is_a?(String)
                                                            params[:user]
                                                          else
                                                            params[:user].id
                                                          end
                                                [:users, user_id]
                                              else
                                                raise Error, ':partnership or :user params are missing!'
                                              end
              user_partnership_path = resource_path[path_key] # get the right path that is associated with the path key
              "#{user_partnership_path}/#{user_partnership_id}/#{sport}"
            elsif not params[:subscription].nil?
              if params[:subscription].is_a?(String)
                params[:subscription]
              else
                "#{params[:subscription].resource_path}/#{params[:subscription].id}"
              end
            else
              raise Error, ':sport or :subscription params are missing!'
            end
          else #otherwise assume its a string
            params
          end
        end


        def deserialize(response)
          hash = JSON.parse(response)
          type = find_out_type(hash)
          raise 'Type error!' if type.nil?
          entry = hash[type]
          entry = entry.merge({'type' => type})
          self.create entry
        end


        def find_out_type(hash)
          Type.constants.each do |constant|
            constant_value = Type.const_get(constant)
            return constant_value if not hash[constant_value].nil?
          end
          nil
        end

      end

    end
  end
end