module RestAdapter
  # This class is responsible for providing access for authentication protected operations.
  # An operation like save, update or delete applied on a object needs authentication.
  # To hide the details and to provide a common interface you can use a AuthProxy object.
  class AuthProxy
    attr_accessor :subject, :auth_params
    # Creates AuthProxy object.
    # It takes as argument a hash with the following properties:
    # { :username => a username,
    #   :password => a password,
    #   :subject => an optional subject}
    #
    # or alternatively a hash as follows:
    # { :user => a user object,
    #   :subject => an optional subject}
    #
    # The property :subject is optional.
    #
    def initialize(params)
      @auth_params = if not params[:user].nil?
                       {
                           username: params[:user].username,
                           password: params[:user].password
                       }
                     else
                       {
                           username: params[:username],
                           password: params[:password]
                       }
                     end

      @subject = params[:subject]
      @auth_header = Helper.basic_auth_encryption(@auth_params)
    end

    # Checks if this AuthProxy object is valid in terms of the user credentials.
    # For validation an authentication request is performed.
    # Only for testing purposes!
    def valid?
      module_name = Module.nesting.last  # workaround corresponds to the prefix RestAdapter
      (module_name::User.authenticate(@auth_params)) != false
    end


    # Applies the save operation on the object if provided, otherwise on the subject.
    #
    # Examples====
    # user.email = 'blahaha'
    # auth_proxy.save(user)
    #
    def save(object=nil)
      params = {authorization: @auth_header}
      if not object.nil? #if object is nil, apply the op on the subject.
        object.save(params)
      elsif not @subject.nil?
        @subject.save(params)
      else
        raise 'AuthProxy does nothing'
      end
    end


    # Applies the delete operation on the object if provided, otherwise on the subject.
    #
    # Examples====
    # auth_proxy.delete(user)
    #
    def delete(object=nil)
      params = {authorization: @auth_header}
      if not object.nil? #if object is nil, apply the op on the subject.
        object.delete(params)
      elsif not @subject.nil?
        @subject.delete(params)
      else
        raise 'AuthProxy does nothing'
      end
    end


    # make a alias for method save
    alias_method :update, :save


    # Delegates each method call that is not supported by this proxy
    # to the subject.
    def method_missing(name, *args, &block)
      # This is basically used for wrapping a user object.
      # The only simple way to get the user credentials without dirty hacking
      # is in the authenticate class method in the User class.
      # Instead of returning a User object the authenticate class method returns a AuthProxy object
      # which acts like user object.
      # So here the user object plays the role of the subject.

      @subject.send(name, *args, &block)
    end

  end
end