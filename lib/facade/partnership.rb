module Facade

  class Partnership
    def self.method_missing(method, *args, &block)
      puts "#{method} called"

      RestAdapter::Models::Partnership.send method, *args, &block
    end
  end

end
