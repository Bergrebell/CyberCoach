require 'test_helper'

class TestUser < Cybercoach::Base

end


class Cybercoach::BaseTest < ActiveSupport::TestCase

   test "test initalization" do
     user = TestUser.new username: 'lexruee', password: 'hidden'
   end

   test "test instance variables" do
     user = TestUser.new username: 'lexruee', password: 'hidden'
     # check if instance variables are created
     assert_not_nil user.username
     assert_not_nil user.password
   end

   test "test instance methods" do
     user = TestUser.new username: 'lexruee', password: 'hidden'
     methods = user.methods
     # check if setters and getters are created
     assert methods.include? :username
     assert methods.include? :username=
     assert methods.include? :password
     assert methods.include? :password=
   end
end
