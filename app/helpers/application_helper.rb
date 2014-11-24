module ApplicationHelper
  def avatar_url(mail)
      gravatar_id = Digest::MD5.hexdigest(mail)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d"
  end
end
