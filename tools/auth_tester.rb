require 'base64'
require 'rest-client'
require 'pp'

def main

  puts 'Please enter a username:'
  username = gets.chomp
  puts 'Please enter a password:'
  password = gets.chomp


  auth = 'Basic ' + Base64.encode64(username + ':' + password).chomp
  options = {
      authorization: auth,
      accept: :xml,
      content_type: :xml
  }

  res = RestClient.get('http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/authenticateduser/',options)
  pp res
end

if __FILE__ == $0
  main
end