require 'pp'
class TestSubscriptionAdapter  < ActiveSupport::TestCase

  test "retrieve a subscription over a user" do
    subscription = RestAdapter::Subscription.retrieve(user: 'newuser4', sport: 'Running')
    assert_not_nil subscription
    assert_not_nil subscription.user

    assert_equal 'newuser4', subscription.user.username
    assert_equal 'Running', subscription.sport.name
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/', subscription.uri
  end


  test "retrieve a subscription over a partnership" do

    # first possibility
    partnership = RestAdapter::Partnership.retrieve first_user: 'newuser4', second_user: 'newuser5'
    assert_not_nil partnership

    subscription = RestAdapter::Subscription.retrieve(partnership: partnership, sport: 'Soccer')
    assert_not_nil subscription

    # second possibility
    subscription = RestAdapter::Subscription.retrieve(partnership: 'newuser4;newuser5', sport: 'Soccer')
    assert_not_nil subscription

    # third possibility
    subscription = RestAdapter::Subscription.retrieve(first_user: 'newuser4', second_user: 'newuser5',
                                                      sport: 'Soccer')

    pp subscription.partnership
    assert_not_nil subscription
    assert_not_nil subscription.partnership
    assert_not_nil subscription.partnership.first_user
    assert_not_nil subscription.partnership.second_user
    assert_equal 'newuser4', subscription.partnership.first_user.username
    assert_equal 'newuser5', subscription.partnership.second_user.username
    assert_equal 'newuser4', subscription.partnership.second_user.partnerships.first.first_user.username

    assert subscription.partnership.second_user.partnerships.first.first_user.friends.size > 0

    assert_equal 'Soccer', subscription.sport.name

  end

  test "create a subscription" do
    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'
    user = RestAdapter::User.retrieve 'alex'
    subscription = RestAdapter::Subscription.new(user: user,
                                                 sport: 'Running',
                                                 public_visible: RestAdapter::Privacy::Public)

    assert_equal '/CyberCoachServer/resources/users/alex/Running', subscription.uri
    assert auth_proxy.authorized?
    res = auth_proxy.save(subscription)
    pp res
  end

end