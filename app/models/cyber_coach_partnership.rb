class CyberCoachPartnership < RestResource::Base

  use_resource 'partnership'
  include RestResource::CyberCoach

  id :id
  properties :id, :uri, :publicvisible, :userconfirmed1, :userconfirmed2, :user1, :user2
  serializable :publicvisible

  def initialize(properties)
    initialize_properties(properties)
    create_accessors
  end

  def entity_resource_uri
    if self.uri.nil?
      self.class.collection_resource_uri + '/' + self.first_user.username + ';' + self.second_user.username
    else
      self.class.base_uri + self.uri
    end
  end

  # Return first user of this partnership.
  def first_user
    user1.kind_of?(CyberCoachUser) ? user1 : CyberCoachUser.new(user1)
  end

  # Return second user of this partnership.
  def second_user
    user2.kind_of?(CyberCoachUser) ? user2 : CyberCoachUser.new(user2)
  end

  def confirmed_by_first_user?
    self.userconfirmed1 == 'true'
  end

  def confirmed_by_second_user?
    self.userconfirmed2 == 'true'
  end

  def active?
    self.confirmed_by_first_user? and self.confirmed_by_second_user?
  end

  def inactive?
    not self.active?
  end

  def confirmed_by?(user)
    username = user.kind_of?(CyberCoachUser) ? user.username : user #support username and cyber coach user
    confirmed = self.user1['username'] == username ? self.userconfirmed1 : self.userconfirmed2
    confirmed == 'true'
  end


  def self.find(params)
    first, second = params.kind_of?(Hash) ? params.values : (list = *params) # support hashes and lists
    id = first + ';' + second
    response =  RestClient.get(self.collection_resource_uri + '/' + id,{
        accept: self.format,
        content_type: self.format
    })
    deserializer = self.get_deserializer
    deserializer.call(response)
  end

end