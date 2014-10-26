module RestAdapter

  module Config

    module CyberCoach

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def base
          'http://diufvm31.unifr.ch:8090'
        end

        def site
          '/CyberCoachServer/resources'
        end

        def deserialize_format
          :json #use json as default value for http header accept
        end

        def serialize_format
          :xml #use json as default value for http header content-type
        end

      end

    end

  end

end