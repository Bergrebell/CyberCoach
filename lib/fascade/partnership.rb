module Fascade

  class Partnership
    def self.method_missing(method, *args, &block)
      puts "#{method} called"

      RestAdapter::Models::User.send method, *args, &block
    end
  end

end
