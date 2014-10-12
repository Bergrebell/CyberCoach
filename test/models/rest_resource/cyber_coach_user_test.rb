require 'test_helper'
require 'pp'

class CyberCoachUserTest < ActiveSupport::TestCase

  test "get five users" do
    users = CyberCoachUser.all query: { start: 0, size: 5 }

    assert_equal(5,users.size)
  end

  test "filter users" do
    find_users = ['lexruee','lexruee5','lexruee11']

    users = CyberCoachUser.find filter: ->(x) do
      find_users.include?(x.username)
    end, query: { start: 0, size: 999}

    users.each do |user|
      assert find_users.include?(user.username)
    end
  end

  test "get user first example" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'lexruee5'
    end
    assert_equal 'lexruee5', user.username
    assert_equal '/CyberCoachServer/resources/users/lexruee5/',user.uri
  end

  test "get user second example" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'timon'
    end
    assert_equal 'timon', user.username
    assert_equal '/CyberCoachServer/resources/users/timon/',user.uri
  end

  test "get user details" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'lexruee5'
    end

    # load all user details
    user = user.load

    assert user.properties.has_key?(:partnerships)
    assert_not_nil(user.partnerships)
    assert_equal("Peter Muller",user.realname)
  end

  test "update email address" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'lexruee6'
    end

    user = user.load

    user.email = 'foobar@test.com'
    user.publicvisible = 2

    # update user and get updated user object
    user = user.update username: 'lexruee6', password: 'test'
    assert_not_nil user

  end

  test "user authentication should succeed" do

    user = CyberCoachUser.authenticate(username: 'alex', password: 'scareface')
    assert user != false
    assert_equal "alex", user.username

    user = CyberCoachUser.authenticate(username: 'MikeShiva', password: '12345')
    assert user != false
    assert_equal "mikeshiva", user.username

    user = CyberCoachUser.authenticate(username: 'timon', password: 'scareface')
    assert user != false
    assert_equal "timon", user.username


    user = CyberCoachUser.authenticate(username: 'moritz', password: 'scareface')
    assert user != false
    assert_equal "moritz", user.username

  end

  test "user authentication should fail" do
    user = CyberCoachUser.authenticate(username: 'alex', password: 'totally wrong password')
    assert_equal false, user
  end

  test "probe username" do
    # check
    assert CyberCoachUser.username_available?('reallystypidlongname')
    assert !CyberCoachUser.username_available?('mila_')
    # check
    assert !CyberCoachUser.username_available?('lexruee5')
  end

  test "create user" do
    mila = CyberCoachUser.new username: 'milaKunis', email: 'mila.kunis@unifr.ch', password: '12345', realname: 'Mila Kunis', publicvisible: RestResource::Privacy::Public
    assert_equal 'milaKunis', mila.username
    assert_not_nil mila.save
  end

  test "delete user" do
    mila = CyberCoachUser.new username: 'milaKunis', email: 'mila.kunis@unifr.ch', password: '12345', realname: 'Mila Kunis', publicvisible: RestResource::Privacy::Public
    mila.delete(username: 'milaKunis', password: '12345')
  end


  test "create user if username is available" do

    if CyberCoachUser.username_available?('MikeShiva')
      shiva = CyberCoachUser.new username: 'MikeShiva', email: 'mike.shiva@unifr.ch', password: '12345', realname: 'Mike Shiva', publicvisible: RestResource::Privacy::Public
      assert_equal 'MikeShiva', shiva.username
      assert_not_nil shiva.save
    end

  end

  test "cyber coach uses only lower case user names" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'mikeshiva'
    end

    assert_not_nil user

    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'MikeShiva'
    end

    assert_nil user
  end

end