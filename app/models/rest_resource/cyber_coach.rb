module RestResource
  module CyberCoach
    def self.included(base)
      base.base_uri 'http://diufvm31.unifr.ch:8090/'
      base.site_uri '/CyberCoachServer/resources/'
      base.resource_path '/' + base.resource.pluralize + '/'
      base.format :xml

      # setup deserializer
      base.use_default_deserializer base.resource, base
      # setup serializer
      base.use_default_serializer base.resource
    end
  end

  # Maps all privacy levels on the cyber coach server as constants.
  # They're accessible using eg.: RestResource::Privacy::Public
  module Privacy
    Private = 0
    Member = 1
    Public = 2
  end

end