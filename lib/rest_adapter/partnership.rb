module RestAdapter

  # This class is responsible for adapting the resource partnership.
  class Partnership < BaseResource

    #getters and setters
    attr_reader :public_visible, :confirmed_by_first_user, :confirmed_by_second_user,
                :first_user, :second_user, :confirmed
    set_resource_path '/partnerships'
    set_resource 'partnership'


    alias_method :confirmed_by_first_user?, :confirmed_by_first_user
    alias_method :confirmed_by_second_user?, :confirmed_by_second_user

    # Defines a customized id for a partnership resource.
    def id
      self.first_user.username + ';' + self.second_user.username
    end


    # Creates a partnership object.
    def initialize(params)
      # default value for all properties is nil!
      @uri = params[:uri]
      @public_visible = params[:public_visible]
      @confirmed_by_first_user = params[:confirmed_by_first_user]
      @confirmed_by_second_user = params[:confirmed_by_second_user]
      @first_user = params[:first_user]
      @second_user = params[:second_user]
      @confirmed = params[:confirmed]
    end


    # Returns true if the given user is associated with this partnership.
    def associated_with?(user)
      username = user.kind_of?(User) ? user.username : user # support usernames and user object
      user_names = self.class.extract_user_names_from_uri(self.uri)
      user_names.include?(username)
    end


    # Returns true if the given user has confirmed this partnership.
    def confirmed_by?(user)
      username = user.kind_of?(User) ? user.username : user # support usernames and user object

      # check if confirmed lookup table is present
      if self.confirmed.nil?
        self.fetch! #fetch details
      end

      self.confirmed[username] == true # table lookup for user 'username'
    end


    # Returns the partner of this user in this partnership.
    def partner_of(user)
      partner = self.first_user.username == user.username ? self.second_user : self.first_user
    end


    # Returns true if this partnership is active. Otherwise it returns false.
    def active?
      self.confirmed_by_first_user and self.confirmed_by_second_user
    end

    def users
      self.class.extract_user_names_from_uri(self.uri)
    end


    # open eigenclass
    class << self

      def create(params)
        if not params.kind_of?(Hash)
          raise ArgumentError, 'Argument is not a hash'
        end

        properties = {
            uri: params['uri'],
            id: params['id'],
            public_visible: params['publicvisible']
        }

        # check if user properties are present
        if not params['user1'].nil? and not params['user2'].nil?
          # this hack is dedicated to my dear friend julian pollack.
          # awesome guy. i have learned a lot from him...
          # create a boolean lookup table to avoid error prone 'if comparisons' with usernames
          # use username as key values
          confirmed = {
              params['user1']['username'] => params['userconfirmed1'],
              params['user2']['username'] => params['userconfirmed2']
          }

          properties = properties.merge({
                                            first_user: User.create(params['user1']),
                                            second_user: User.create(params['user2']),
                                            confirmed: confirmed,
                                            confirmed_by_first_user: params['userconfirmed1'],
                                            confirmed_by_second_user: params['userconfirmed2']
                                        })
        else # if not extract user names from the uri
          first_user, second_user  = self.extract_user_names_from_uri(params['uri'])
          properties = properties.merge({
                                            first_user: User.create('username' => first_user),
                                            second_user: User.create('username' => second_user)
                                        })
        end

        new(properties)
      end


      def serialize(partnership)
        if not partnership.kind_of?(Partnership)
          raise ArgumentError, 'Argument must be of type partnership'
        end
        hash = {
            publicvisible: partnership.public_visible
        }
        hash.to_xml(root: 'partnership')
      end


      # Returns a list containing two user names.
      def extract_user_names_from_uri(uri)
        resource = uri.split('/').last # get last part of the uri
        resource = resource[0...-1] if resource[-1] == '/' # remove last forward slash if present
        resource.split(';')
      end

    end # end of eigenclass

  end # end of class Partnership
end