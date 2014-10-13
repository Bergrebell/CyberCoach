class CyberCoachSport < RestResource::Base

  use_resource 'sport'
  include RestResource::CyberCoach

  id :id
  # these properties are all available using conventional setter and getters
  properties :id, :name, :uri, :description

end