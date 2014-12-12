module Facade

  class User
    include Facade::Wrapper


    def self.wrap(a_rails_user)
      a_coach_user = Coach.user a_rails_user.username
      UserProxy.new a_rails_user, a_coach_user
    end


    def self.create(params={})
      rails_user = ::User.new(params)
      UserProxy.new rails_user
    end


    def self.authenticate(username, password)
      coach_user = Coach.authenticate(username, password)
      rails_user = ::User.find_by username: username

      if coach_user
        UserProxy.new rails_user, coach_user
      else
        false
      end
    end

  end


  class UserProxy
    include Facade::RailsModel

    attr_reader :rails_object, :coach_object

    def initialize(rails_user, coach_user=OpenStruct.new)
      @rails_object = rails_user
      @coach_object = coach_user
    end

    def self.method_missing(meth, *args, &block)
      ::User.send meth, *args, &block
    end


    def method_missing(meth, *args, &block)
      @rails_object.send meth, *args, &block
    end


    def real_name
      @coach_object.real_name
    end


    def email
      @coach_object.email
    end


    def public_visible
      @coach_object.public_visible
    end


    def username
      @rails_object.username
    end


    def password
      @rails_object.password
    end


    # Persists the created user.
    # Returns true if persisting the user succeeds otherwise false.
    #
    # ==== Example
    # user.save
    #
    def save
      if @rails_object.valid?
        coach_user = Coach.create_user do |user|
          user.real_name = @rails_object.real_name
          user.username = @rails_object.username
          user.email = @rails_object.email
          user.password = @rails_object.password
        end
        raise 'Error' unless coach_user
        coach_user ? @rails_object.save : false
      else
        false
      end
    end


    def update(params={})
      begin
        proxy = Coach4rb::Proxy::Access.new(@rails_object.username, @rails_object.password, Coach)
        updated_user = proxy.update_user(@coach_object) do |user|
          user.real_name = params[:real_name]
          user.email = params[:email]
          @rails_object.assign_attributes(params)
          raise 'Error' unless @rails_object.save
        end
        raise 'Error' unless updated_user

        @rails_object = ::User.find_by id: @rails_object.id
        @coach_object = updated_user
        true
      rescue
        false
      end
    end


    def friends
      Facade::User.query do
        @rails_object.friends
      end
    end

  end


end