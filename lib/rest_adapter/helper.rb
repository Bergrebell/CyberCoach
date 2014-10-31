module RestAdapter

  module Helper
    # Builds a basic auth string and returns the final basic auth string.
    # params = {username: username, password: password }
    def self.basic_auth_encryption(params)
      'Basic ' + Base64.encode64("#{params[:username]}:#{params[:password]}")
    end

    DateTimeInjector = ->(time) {Time.at(time/1000).to_datetime}
  end

end