require 'test_helper'
require 'pp'

class TestRestAdapter  < ActiveSupport::TestCase

  # Test class methods

  test "user resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::User.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::User.site
    assert_equal '/users', RestAdapter::User.resource_path
    assert_equal 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users', RestAdapter::User.collection_uri
  end

  test "create user entity uri" do
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users/alex'
    entity_uri = RestAdapter::User.create_entity_uri 'alex'
    assert_equal should_be, entity_uri
  end



  test "create user object" do
    user = RestAdapter::User.new username: 'alex', email: 'alex@test.com', password: 'test', public_visible: RestAdapter::Privacy::Public
    assert_equal '/CyberCoachServer/resources/users/alex', user.uri
    assert_equal 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users/alex', user.entity_uri

    assert_equal 'alex', user.username
    assert_equal 'test', user.password
    assert_equal 'alex@test.com', user.email
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end

  test "retrieve a user" do
    user = RestAdapter::User.retrieve 'moritz'
    assert_not_nil user
    assert_equal 'moritz', user.username
    assert_equal RestAdapter::Privacy::Public, user.public_visible
    assert_equal 'Moritz Cheng', user.real_name
    assert_equal '/CyberCoachServer/resources/users/moritz/', user.uri
  end

  test "retrieve a collection of five users" do
    users = RestAdapter::User.all query: {start: 0, size: 5}
    assert_not_nil users
    assert_equal 5, users.size
  end

  test "retrieve a all users" do
    users = RestAdapter::User.all
    assert_not_nil users
  end

  test "filter users" do
    friends = ['alex','moritz','timon']
    users = RestAdapter::User.all filter: ->(user) { friends.include?(user.username)}
    assert_equal 3, users.size
  end

  test "fetch details of a user" do
    users = RestAdapter::User.all filter: ->(user) { user.username == 'moritz' }
    user = users.first
    user.fetch!
    assert_equal 'Moritz Cheng', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end

  test "fetch details of a user in functional way" do
    users = RestAdapter::User.all filter: ->(user) { user.username == 'moritz' }
    user = users.first
    user = user.fetch
    assert_equal 'Moritz Cheng', user.real_name
       assert_equal RestAdapter::Privacy::Public, user.public_visible
  end

  test "authenticate user" do
    user = RestAdapter::User.authenticate username: 'alex', password: 'scareface'

    assert user != false
    assert_equal 'alex', user.username
  end

  test "if user name is available" do

    # a name that is too short, should fail
    check = RestAdapter::User.username_available?('mor')
    assert check==false

    # a name that is already taken, should fail
    check = RestAdapter::User.username_available?('moritz')
    assert check==false

    # invalid name should fail
    check = RestAdapter::User.username_available?('moritz___')
    assert check==false

    # should succeed
    check = RestAdapter::User.username_available?('reallystupidlongname')
    assert check==true
  end


  test "update user" do
    user = RestAdapter::User.retrieve 'moritz'
    user.email = 'moritz.cheng@unifr.ch'

    auth_proxy = RestAdapter::AuthProxy.new username: 'moritz', password: 'scareface'
    auth_proxy.save(user)

    test_user = RestAdapter::User.retrieve 'moritz'
    assert_equal 'moritz.cheng@unifr.ch', test_user.email

  end


  test "create and delete user" do
    auth_proxy = RestAdapter::AuthProxy.new username: 'dummy', password: 'dummy'
    user = RestAdapter::User.new(username: 'dummy',
                                 password: 'dummy',
                                 real_name: 'dummy user',
                                 email: 'dummy@dummy.ch',
                                 public_visible: RestAdapter::Privacy::Public
    )

    assert user.save
    sleep 2

    user = RestAdapter::User.retrieve 'dummy'
    assert user!= false

    assert auth_proxy.delete(user)
    sleep 2

    user = RestAdapter::User.retrieve 'dummy'
    assert user== false

  end


end