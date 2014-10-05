class User < Cybercoach::Base

  # set resource identifier
  @@id = :username

  @@fields = :username, :password, :email, :realname

end
