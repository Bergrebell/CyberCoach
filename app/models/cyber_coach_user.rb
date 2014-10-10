class CyberCoachUser < RestResource::Base

  id :username

  properties :username, :password, :email, :publicvisible, :partnerships, :uri, :datecreated

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'

  resource_path '/users/'

  format :xml

  # setup deserializer
  deserializer do |xml|
    hash = Hash.from_xml(xml)
    if hash['list']
      users = hash['list']['users']['user']
      users = users.map {|params| CyberCoachUser.new params}
    else
      params = hash['user']
      user = CyberCoachUser.new params
    end
  end

  # setup serializer
  serializer do |properties,changed|
    keys = changed.select {|k,v| v==true}.keys
    changed_properties = properties.select {|k,v| keys.include?(k)}
    changed_properties.to_xml(root: 'user')
  end


  def self.username_available?(username)
    # check if username is alphanumeric and that it contains least 4 letters
    if  not /^[a-zA-Z0-9]{4,}$/ =~ username
      return false
    end
    # try and error: check if username is already used... i'm feeling dirty...
    begin
      response = RestClient.get(self.resource_uri + '/' + username, {
          content_type: self.format,
          accept: self.format
      })
      false
    rescue
      true
    end
  end

  def self.authenticate(params)
    #TODO: implement that
    false
  end

end