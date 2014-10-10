require 'test_helper'



class CyberCoachUserTest < ActiveSupport::TestCase

  test "get five users" do
    users = CyberCoachUser.all query: { start: 0, size: 5 }

    assert_equal(5,users.size)
  end

  test "filter users" do
    find_users = ['lexruee','lexruee5','lexruee11']

    users = CyberCoachUser.all filter: ->(x) do
      find_users.include?(x.username)
    end, query: { start: 0, size: 999}

    users.each do |user|
      assert find_users.include?(user.username)
    end
  end

  test "get user" do
    user = CyberCoachUser.find_first filter: ->(x) do
      x.username == 'lexruee5'
    end
    assert_not_nil user
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

    user = CyberCoachUser.authenticate(username: 'lexruee6', password: 'test')
    assert_not_equal false,user
    assert_equal "lexruee6", user.username

  end

  test "user authentication should fail" do
    user = CyberCoachUser.authenticate(username: 'lexruee6', password: 'totally wrong password')
    assert_equal false,user
  end

  test "probe username" do
    # check
    assert CyberCoachUser.username_available?('alex')
    assert !CyberCoachUser.username_available?('mila_')
    # check
    assert !CyberCoachUser.username_available?('lexruee5')
  end

  test "create user" do

    mila = CyberCoachUser.new username: 'milaKunis', email: 'mila.kunis@unifr.ch', password: '12345', realname: 'Mila Kunis', publicvisible: 2
    assert_equal 'milaKunis', mila.username
    assert_not_nil mila.save
  end

  test "delete user" do
    mila = CyberCoachUser.new username: 'milaKunis', email: 'mila.kunis@unifr.ch', password: '12345', realname: 'Mila Kunis', publicvisible: 2
    mila.delete(username: 'milaKunis', password: '12345')
  end

end