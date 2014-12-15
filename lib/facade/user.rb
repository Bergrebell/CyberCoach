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
      if coach_user && coach_user.public_visible == Coach4rb::Privacy::Public
        get_or_create_rails_user(coach_user, username, password)
      else
        false
      end
    end


    def self.get_or_create_rails_user(coach_user, username, password )
      rails_user = ::User.find_by username: username
      if rails_user.nil? # create a rails user
        user = ::User.new username: username, password: password
        user.save(validate: false, run_callbacks: false)

        # subscribe user to all sports
        proxy = Coach4rb::Proxy::Access.new username, password, Coach
        [:running, :soccer, :boxing, :cycling].each do |sport|
          Thread.new do
            proxy.subscribe(coach_user, sport)
          end
        end
        rails_user = ::User.find_by username: username
      end
      rails_user
    end


  end

end