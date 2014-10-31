require 'pp'
class TestAuthProxy  < ActiveSupport::TestCase

  test "test auth proxy" do
    user = RestAdapter::Models::User.retrieve 'alex'
    user.email = 'alex.r@unifr.ch'

    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'

    assert auth_proxy.save(user)

  end

  test 'if auth proxy is valid' do
    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'
    assert auth_proxy.authorized?
  end

end