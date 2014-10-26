require 'pp'

class TestRestAdapter < ActiveSupport::TestCase

  # Test class methods

  test "user resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::User.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::User.site
    assert_equal '/users', RestAdapter::User.resource_path
    assert_equal 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users', RestAdapter::User.collection_uri
  end

  test "create user entity uri" do
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users/alex'
    entity_uri = RestAdapter::User.create_absolute_resource_uri 'alex'
    assert_equal should_be, entity_uri
  end


  test "create user object" do
    user = RestAdapter::User.new(
        username: 'alex',
        email: 'alex@test.com',
        password: 'test',
        public_visible: RestAdapter::Privacy::Public
    )

    assert_equal '/CyberCoachServer/resources/users/alex', user.uri

    assert_equal 'alex', user.username
    assert_equal 'test', user.password
    assert_equal 'alex@test.com', user.email
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "retrieve a user" do
    user = RestAdapter::User.retrieve 'asarteam1'
    assert_not_nil user
    assert_equal 'asarteam1', user.username
    assert_equal RestAdapter::Privacy::Public, user.public_visible
    assert_equal 'asarteam1', user.real_name
    assert_equal '/CyberCoachServer/resources/users/asarteam1/', user.uri
  end


  test "retrieve a collection of five users" do
    users = RestAdapter::User.all(query: {start: 0, size: 5})
    assert_not_nil users
    assert_equal 5, users.size
  end


  test "retrieve a all users" do
    users = RestAdapter::User.all
    assert_not_nil users
  end


  test "filter users" do
    friends = ['asarteam1','asarteam2','asarteam3','asarteam4','asarteam5']
    users = RestAdapter::User.all filter: ->(user) { friends.include?(user.username) }
    assert_equal 5, users.size
  end


  test "fetch details of a user" do
    users = RestAdapter::User.all filter: ->(user) { user.username == 'asarteam1' }
    user = users.first
    user.fetch!
    assert_equal 'asarteam1', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "fetch details of a user in functional way" do
    users = RestAdapter::User.all filter: ->(user) { user.username == 'asarteam1' }
    user = users.first
    user = user.fetch
    assert_equal 'asarteam1', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "lazy loading on user object" do
    users = RestAdapter::User.all filter: ->(user) { user.username == 'asarteam1' }
    user = users.first
    assert_equal 'asarteam1', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "authenticate user" do
    user = RestAdapter::User.authenticate username: 'asarteam1', password: 'scareface'
    assert user
    pp user.as_hash
    assert user != false
    assert_equal 'asarteam1', user.username
  end


  test "user as hash" do
    user = RestAdapter::User.authenticate username: 'asarteam1', password: 'scareface'
    assert user
    user_hash = user.as_hash
    assert user_hash
    assert_equal 'asarteam1', user_hash['username']
    assert_equal 'asarteam1', user_hash['real_name']
    assert_equal 2, user_hash['public_visible']
    assert_equal 'asarteam1@test.com', user_hash['email']
  end


  test "if user name is available" do

    # a name that is too short, should fail
    check = RestAdapter::User.username_available?('mor')
    assert check==false

    # a name that is already taken, should fail
    check = RestAdapter::User.username_available?('asarteam1')
    assert check==false

    # invalid name should fail
    check = RestAdapter::User.username_available?('moritz___')
    assert check==false

    # should succeed
    check = RestAdapter::User.username_available?('reallystupidlongname')
    assert check==true
  end


  test "update user" do
    user = RestAdapter::User.retrieve 'asarteam1'
    user.email = 'asarteam1@test.com'

    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam1', password: 'scareface', session: {:user => { :friends => nil, :partnerships => nil}}
    assert auth_proxy.authorized?
    auth_proxy.save(user)

    test_user = RestAdapter::User.retrieve 'asarteam1'
    assert_equal 'asarteam1@test.com', test_user.email
  end


  test "create and delete user" do
    user = RestAdapter::User.new(
        username: 'dummy',
        email: 'dummy@test.com',
        password: 'dummy',
        real_name: 'dummy',
        public_visible: RestAdapter::Privacy::Public
    )

    pp user.serialize
    auth_proxy = RestAdapter::AuthProxy.new username: 'dummy', password: 'dummy', session: {:user => { :friends => nil, :partnerships => nil}}

    assert auth_proxy.save(user)

    sleep 2
    user = RestAdapter::User.retrieve 'dummy'
    assert user!= false

    assert auth_proxy.delete(user)
    sleep 2

    user = RestAdapter::User.retrieve 'dummy'
    assert user== false
  end


  test "create some users" do
    if false
      usernames = (1..5).to_a.map { |a| 'asarteam' + a.to_s}
      usernames.each do |username|
        email = "#{username}@test.com"
        user = RestAdapter::User.new(
            username: username,
            email: email,
            password: 'scareface',
            public_visible: RestAdapter::Privacy::Public,
            real_name: username
        )
        assert user.save
      end
    end
  end


end