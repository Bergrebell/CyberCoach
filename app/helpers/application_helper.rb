module ApplicationHelper

  def gravatar_tag(email,options={})
    options[:s] ||= '125' # default option
    md5 = Digest::MD5.hexdigest(email.downcase)
    img_url = "http://gravatar.com/avatar/#{md5}.png?s=#{options[:s]}&d"
    image_tag img_url
  end

end
