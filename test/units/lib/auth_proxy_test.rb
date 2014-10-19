require 'test_helper'
require 'pp'
class TestAuthProxy  < ActiveSupport::TestCase

  test "test auth proxy" do
    user = RestAdapter::User.retrieve 'alex'
    user.email = 'alex.r@unifr.ch'

    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'

    assert auth_proxy.save(user)

  end

  test 'if auth proxy is valid' do
    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'
    assert auth_proxy.valid?
  end

end