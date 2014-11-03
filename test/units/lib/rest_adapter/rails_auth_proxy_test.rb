require 'pp'
class TestRailsAuthProxy  < ActiveSupport::TestCase



  test "test auth proxy" do

    user = Facade::User.authenticate username: 'alex', password: 'scareface'
    assert user.rails_model
    user = Facade::User.find_by name: 'alex'
    pp user
    assert user.is_a?(Facade::User)
    rails_auth_proxy = RestAdapter::Proxy::RailsAuth.new user_id: user.rails_model.id
    pp rails_auth_proxy
    assert_not_nil rails_auth_proxy
    assert rails_auth_proxy.authorized?

  end



end