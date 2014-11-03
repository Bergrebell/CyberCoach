require 'pp'


MyUser = RestAdapter::Models::User
class MyUser
      include RestAdapter::Behaviours::Accessible
end


MySubscription = RestAdapter::Models::Subscription
class MySubscription
  include RestAdapter::Behaviours::Accessible
end


class TestAccessProxy < ActiveSupport::TestCase


  test "if private reads works" do
    subject = RestAdapter::Models::User.authenticate username: 'privatealex', password: 'scareface'
    auth_header = RestAdapter::Helper.basic_auth_encryption(username: 'privatealex', password: 'scareface')
    dao_user = RestAdapter::Proxy::Access.new subject: subject, auth_header: auth_header
    assert dao_user.authorized?
    assert_not_nil dao_user.real_name
    dao_user.real_name = 'bobby'
    assert dao_user.save

  end


  test "if private reads works 2" do
    subject = RestAdapter::Models::User.authenticate username: 'privatealex', password: 'scareface'
    auth_header = RestAdapter::Helper.basic_auth_encryption(username: 'privatealex', password: 'scareface')
    dao_user = RestAdapter::Proxy::Access.new subject: subject, auth_header: auth_header
    pp dao_user.real_subject
    pp dao_user.subscriptions

    s = dao_user.subscriptions.first
    pp s


  end



end