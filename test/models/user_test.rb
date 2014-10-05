require 'test_helper'

class UserTest < ActiveSupport::TestCase

   test "get all users" do
     users = User.all
     assert_not_empty users
   end

  test "get six users" do
    users = User.find :start => 0, :size => 6
    assert_equal(6, users.size)
  end

  test "create and delete user" do
    u = User.new username: 'lexruee8', password: 'test', email: 'test4444@test.com', publicvisible: 2, realname: 'Peter Hans'
    u.save
    sleep 1.5
    user = User.find_first(filter: ->(user) {user.username == 'lexruee8'})
    assert_equal('lexruee8',user.username)
    user.password = 'test'
    user.delete
    sleep 1.5

    user = User.find_first(filter: ->(user) {user.username == 'lexruee8'})
    assert_nil(user)
  end

   test "filter users" do
     users = User.find(filter: ->(user) {user.username == 'lexruee5'})
     assert_equal(1,users.size)
   end

   test "get first user" do
     user = User.find_first(filter: ->(user) {user.username == 'lexruee5'})
     assert_equal('lexruee5',user.username)
   end

   test "get user details" do
     user = User.find_first(filter: ->(user) {user.username == 'lexruee5'})
     user = user.load()
     assert_equal('test1010101@test.com',user.email)
   end

   test "update user" do
     user = User.find_first(filter: ->(user) {user.username == 'lexruee5'})
     user = user.load
     assert_equal("Peter Muller", user.realname)
     user.realname = 'Peter Hans'
     user.password = 'test'
     user.update

     sleep 1.5

     user = User.find_first(filter: ->(user) {user.username == 'lexruee5'})
     user = user.load
     assert_equal("Peter Hans", user.realname)

     sleep 1.5

     user.realname = 'Peter Muller'
     user.password = 'test'
     user.update
   end

end
