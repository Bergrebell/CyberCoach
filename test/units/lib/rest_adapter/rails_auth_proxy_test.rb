require 'pp'
class TestRailsAuthProxy  < ActiveSupport::TestCase



  test "test auth proxy" do

    Facade::User.authenticate username: 'alex', password: 'scareface'
    user = Facade::User.find_by name: 'alex'
    rails_auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: user.id
    assert_not_nil rails_auth_proxy
    assert rails_auth_proxy.authorized?

  end



end