require 'pp'
class TestAuthProxy  < ActiveSupport::TestCase

  test "test auth proxy" do
    user = RestAdapter::Models::User.retrieve 'alex'
    user.email = 'alex.r@unifr.ch'

    auth_proxy = RestAdapter::Proxy::Auth.new username: 'alex', password: 'scareface'

    assert auth_proxy.save(user)

  end

  test 'if auth proxy is valid' do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'alex', password: 'scareface'
    assert auth_proxy.authorized?
  end

  test "if private access works" do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'privatealex', password: 'scareface'
    assert auth_proxy.authorized?
    fetched_user = auth_proxy.subject(RestAdapter::Models::User).retrieve 'privatealex'
    assert fetched_user
    RestAdapter::Models::Sport::Types.each do |sport|
      hash = {
          user: fetched_user,
          sport: sport,
          public_visivle: RestAdapter::Privacy::Private
      }
      subscription = RestAdapter::Models::Subscription.new(hash)
      assert auth_proxy.save(subscription)
    end

  end

  test "if private reads on user works" do
      auth_proxy = RestAdapter::Proxy::Auth.new username: 'privatealex', password: 'scareface'
      assert auth_proxy.authorized?

      fetched_user = auth_proxy.subject(RestAdapter::Models::User).retrieve 'privatealex'
      fetched_user.subscriptions.each do |s|
        pp s.uri
      end

  end

  test "if private reads on subcription works " do
    auth_proxy = RestAdapter::Proxy::Auth.new username: 'privatealex', password: 'scareface'
    assert auth_proxy.authorized?

    user = RestAdapter::Models::User.retrieve 'privatealex'

    subscription = auth_proxy.subject(RestAdapter::Models::Subscription).retrieve user: user, sport: 'running'
    pp subscription

  end

end