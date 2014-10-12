module RestResource
  # Maps all privacy levels on the cyber coach server as constants.
  # They're accessible using eg.: RestResource::Privacy::Public
  module Privacy
    Private = 0
    Member = 1
    Public = 2
  end

  def self.table_name_prefix
    'rest_resource_'
  end
end
