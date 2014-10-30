module Facade

  class SportSession
    def self.method_missing(method, *args, &block)
      puts "#{method} called"

      Models::User.send method, *args, &block
    end
  end

end
