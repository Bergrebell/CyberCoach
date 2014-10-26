module RestAdapter

  # This class is responsible for adapting the resource partnership.
  class Partnership < BaseResource

    #getters and setters
    attr_reader :public_visible, :confirmed_by_first_user, :confirmed_by_second_user,
                :first_user, :second_user, :confirmed

    set_resource_path '/partnerships'
    set_resource 'partnership'

    deserialize_properties :id, :uri, :user1 => :first_user, :user2 => :second_user,
                           :userconfirmed1 => :confirmed_by_first_user,
                           :userconfirmed2 => :confirmed_by_second_user,
                           :publicvisible => :public_visible

    serialize_properties :public_visible


    inject :first_user => module_name::User, :second_user => module_name::User

    after_deserialize  do |params|
      if not params['user1'].nil? and not params['user2'].nil?
        {:confirmed => {params['user1']['username'] => params['userconfirmed1'],
                        params['user2']['username'] => params['userconfirmed2']}
        }
      else
        first_user, second_user = self.extract_user_names_from_uri(params['uri'])
        { first_user: {'username' => first_user},
          second_user: {'username' => second_user} }
      end
    end

    alias_method :confirmed_by_first_user?, :confirmed_by_first_user
    alias_method :confirmed_by_second_user?, :confirmed_by_second_user

    # Defines a customized id for a partnership resource.
    def id
      self.first_user.username + ';' + self.second_user.username
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

      def retrieve(params)
        id = if params.is_a?(Hash) # check if hash
               raise ArgumentError, 'Argument first_user / second user is missing.' if params[:first_user].nil? or params[:second_user].nil?
               # support both usernames and users
               first_user = params[:first_user].is_a?(String) ? params[:first_user] : params[:first_user].username
               second_user = params[:second_user].is_a?(String) ? params[:second_user] : params[:second_user].username
               "#{first_user};#{second_user}"
             else # otherwise assume it's a string
               params
             end
        super(id)
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