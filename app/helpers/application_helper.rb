module ApplicationHelper

  def gravatar_tag(email,options={})
    options[:s] ||= '125' # default option
    md5 = Digest::MD5.hexdigest(email.downcase)
    img_url = "http://gravatar.com/avatar/#{md5}.png?s=#{options[:s]}&d"
    image_tag img_url, options
  end

  def achievement_tag(icon_path,options={})
    image_tag "achievement_icons/#{icon_path}.svg", options
  end

end
