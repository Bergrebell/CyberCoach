require 'pp'

class TestRestAdapter < ActiveSupport::TestCase

  # Test class methods

  test "user resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::Models::User.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::Models::User.site
    assert_equal '/users', RestAdapter::Models::User.resource_path
    assert_equal 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users', RestAdapter::Models::User.collection_uri
  end

  test "create user entity uri" do
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users/alex'
    entity_uri = RestAdapter::Models::User.create_absolute_resource_uri 'alex'
    assert_equal should_be, entity_uri
  end


  test "create user object" do
    user = RestAdapter::Models::User.new(
        username: 'alex',
        email: 'alex@test.com',
        password: 'test',
        public_visible: RestAdapter::Privacy::Public
    )

    assert_equal '/CyberCoachServer/resources/users/alex', user.uri

    assert_equal 'alex', user.id
    assert_equal 'alex', user.username
    assert_equal 'test', user.password
    assert_equal 'alex@test.com', user.email
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "retrieve a user" do
    user = RestAdapter::Models::User.retrieve 'asarteam0'
    assert_not_nil user
    assert_equal 'asarteam0', user.username
    assert_equal nil, user.password
    assert_equal RestAdapter::Privacy::Public, user.public_visible
    assert_equal 'asarteam0', user.real_name
    assert_equal '/CyberCoachServer/resources/users/asarteam0/', user.uri
  end


  test "retrieve a collection of five users" do
    users = RestAdapter::Models::User.all(query: {start: 0, size: 5})
    assert_not_nil users
    assert_equal 5, users.size
  end


  test "retrieve a all users" do
    users = RestAdapter::Models::User.all
    assert_not_nil users
  end


  test "filter users" do
    friends = ['asarteam0','asarteam2','asarteam3','asarteam4','asarteam5']
    users = RestAdapter::Models::User.all filter: ->(user) { friends.include?(user.username) }
    assert_equal 5, users.size
  end


  test "fetch details of a user" do
    users = RestAdapter::Models::User.all filter: ->(user) { user.username == 'asarteam0' }
    user = users.first
    user.fetch!
    assert_equal 'asarteam0', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "fetch details of a user in functional way" do
    users = RestAdapter::Models::User.all filter: ->(user) { user.username == 'asarteam0' }
    user = users.first
    user = user.fetch
    assert_equal 'asarteam0', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "lazy loading on user object" do
    users = RestAdapter::Models::User.all filter: ->(user) { user.username == 'asarteam0' }
    user = users.first
    assert_equal 'asarteam0', user.real_name
    assert_equal RestAdapter::Privacy::Public, user.public_visible
  end


  test "authenticate user" do
    user = RestAdapter::Models::User.authenticate username: 'asarteam0', password: 'scareface'
    assert user
    pp user.as_hash
    assert user != false
    assert_equal 'asarteam0', user.username
  end


  test "user as hash" do
    user = RestAdapter::Models::User.authenticate username: 'asarteam0', password: 'scareface'
    assert user
    user_hash = user.as_hash
    assert user_hash
    assert_equal 'asarteam0', user_hash['username']
    assert_equal 'asarteam0', user_hash['real_name']
    assert_equal 2, user_hash['public_visible']
    assert_equal 'asarteam0@test.com', user_hash['email']
  end





  test "update a user" do
    user = RestAdapter::Models::User.retrieve 'asarteam0'
    user.email = 'asarteam0@test.com'

    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam0', password: 'scareface', session: {:user => { :friends => nil, :partnerships => nil}}
    assert auth_proxy.authorized?
    auth_proxy.save(user)

    test_user = RestAdapter::Models::User.retrieve 'asarteam0'
    assert_equal 'asarteam0@test.com', test_user.email
  end


  test "create and delete a user" do
    user = RestAdapter::Models::User.new(
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
    user = RestAdapter::Models::User.retrieve 'dummy'
    assert user!= false

    assert auth_proxy.delete(user)
    sleep 2

    user = RestAdapter::Models::User.retrieve 'dummy'
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


  test "retrive user asarteam0" do
    user = RestAdapter::Models::User.retrieve 'asarteam0'
  end


end