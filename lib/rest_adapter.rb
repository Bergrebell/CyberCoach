require 'addressable/uri'
module RestAdapter

  # Helper modules

  module Privacy
    Privat = 0
    Member = 1
    Public = 2
  end

  module Helper
    # Builds a basic auth string and returns the final basic auth string.
    # params = {username: username, password: password }
    def self.basic_auth_encryption(params)
      'Basic ' + Base64.encode64("#{params[:username]}:#{params[:password]}")
    end
  end

end
