class CyberCoachUser < RestResource::Base

  use_resource 'user'
  include RestResource::CyberCoach

  id :username
  properties :username, :password, :realname, :email, :publicvisible,  :uri, :datecreated

  # Checks if a user name is available on the cyber coach webservice.
  # Returns false if the username is already taken or if the username is not alphanumeric string with at least 4 letters.
  # Otherwise it returns true.
  # It uses a string as fir the argument username.
  #
  def self.username_available?(username)
    # check if username is alphanumeric and that it contains least 4 letters
    if  not /^[a-zA-Z0-9]{4,}$/ =~ username
      return false
    end
    # try and error: check if username is already used... i'm feeling dirty...
    begin
      response = RestClient.get(self.collection_resource_uri + '/' + username, {
          content_type: self.format,
          accept: self.format
      })
      false
    rescue
      true
    end
  end

  # Authenticates a user against the cyber coach webservice.
  # It uses a hash as argument with the following properties:
  # params = { username: username, password: password }
  #
  def self.authenticate(params)
    begin
      response = RestClient.get(self.base_uri + self.site_uri + '/authenticateduser/', {
          content_type: self.format,
          accept: self.format,
          authorization: self.basic_auth_encryption(params)
      })
      deserializer = self.get_deserializer
      user = deserializer.call(response)
    rescue
      false
    end
  end

  def proposes_partnership(params)
    partnership = CyberCoachPartnership.new user1: self, user2: params[:to], publicvisible: params[:publicvisible]
    partnership.save(params)
  end

  alias_method :confirms_partnership, :proposes_partnership

  def partnerships
    if @properties[:partnerships].nil?
      @properties[:partnerships] = self.load.properties[:partnerships]['partnership'].map {|p| CyberCoachPartnership.new p }
    else
      @properties[:partnerships]
    end
  end

end