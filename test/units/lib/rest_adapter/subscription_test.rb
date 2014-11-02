require 'pp'
class TestSubscriptionAdapter  < ActiveSupport::TestCase

  test "retrieve a subscription over a uri" do
      subscription = RestAdapter::Models::Subscription.retrieve('/users/newuser4/running/')
  end


  test "uri of a subscription on retrieving" do
    subscription = RestAdapter::Models::Subscription.retrieve('/users/newuser4/running/')
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/', subscription.uri
  end


  test "uri of a subscription on creation" do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'asarteam2', password: 'scareface'
    user = RestAdapter::Models::User.retrieve 'asarteam2'
    running = RestAdapter::Models::Sport.new name: 'Running'
    subscription = RestAdapter::Models::Subscription.new(user: user,
                                                         sport: running,
                                                         public_visible: RestAdapter::Privacy::Public)

    assert_equal '/CyberCoachServer/resources/users/asarteam2/Running/', subscription.uri
  end


  test "retrieve a subscription over a user" do
    user = RestAdapter::Models::User.new username: 'newuser4'
    subscription = RestAdapter::Models::Subscription.retrieve(user: user, sport: 'running')
    assert_not_nil subscription
    assert_not_nil subscription.user

    assert_equal 'newuser4', subscription.user.username
    assert_equal 'Running', subscription.sport.name
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/', subscription.uri
  end


  test "retrieve a subscription over a username" do
    subscription = RestAdapter::Models::Subscription.retrieve(user: 'newuser4', sport: 'running')
    assert_not_nil subscription
    assert_not_nil subscription.user

    assert_equal 'newuser4', subscription.user.username
    assert_equal 'Running', subscription.sport.name
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/', subscription.uri
  end


  test "retrieve a subscription over a user object" do
    user = RestAdapter::Models::User.new username: 'newuser4'
    subscriptions = user.subscriptions
    assert_not_nil subscriptions
    subscription = subscriptions.detect {|s| s.sport.name == 'Running' }
    assert_not_nil subscription.user
    assert_equal 'newuser4', subscription.user.username
    assert_equal 'Running', subscription.sport.name
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/', subscription.uri
  end


  test "retrieve a subscription over a partnership" do
    partnership  = RestAdapter::Models::Partnership.retrieve first_user: 'newuser4', second_user: 'newuser5'
    subscription = RestAdapter::Models::Subscription.retrieve(partnership: partnership, sport: 'Soccer')
    pp subscription

    assert_not_nil subscription

    assert_not_nil subscription
    assert_not_nil subscription.partnership
    assert_not_nil subscription.partnership.first_user
    assert_not_nil subscription.partnership.second_user
    assert_equal 'newuser4', subscription.partnership.first_user.username
    assert_equal 'newuser5', subscription.partnership.second_user.username
    assert_equal 'newuser4', subscription.partnership.second_user.partnerships.first.first_user.username

    assert_equal 'Soccer', subscription.sport.name

  end


  test "create a subscription" do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'asarteam2', password: 'scareface'
    user = RestAdapter::Models::User.retrieve 'asarteam2'
    running = RestAdapter::Models::Sport.new name: 'Running'
    subscription = RestAdapter::Models::Subscription.new(user: user,
                                                 sport: running,
                                                 public_visible: RestAdapter::Privacy::Public)

    assert_equal '/CyberCoachServer/resources/users/asarteam2/Running/', subscription.uri
    assert auth_proxy.authorized?
    res = auth_proxy.save(subscription)
  end


  test "delete subscription" do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'asarteam2', password: 'scareface'
    user = RestAdapter::Models::User.retrieve 'asarteam2'
    assert_not_nil user.subscriptions
    subscription = user.subscriptions.detect {|s| s.sport.name == 'Running'}
    assert_not_nil subscription
    assert auth_proxy.authorized?
    assert auth_proxy.delete(subscription)
  end

end