module Facade

  # Facade class

  class User
    include Facade::Wrapper

    def self.wrap(a_rails_user)
      a_rails_user
    end


    def self.create(params={})
      ::User.new(params)
    end


    def self.authenticate(username, password)
      coach_user = Coach.authenticate(username, password)
      if coach_user
        ::User.find_by username: username
      else
        false
      end
    end


  end

end