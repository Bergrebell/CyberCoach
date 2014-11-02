require 'test_helper'
require 'pp'
class TestSportSessionFacade < ActiveSupport::TestCase


  test "if creating a new sport session succeeds using create" do

    rails_user = ::User.new name: 'asarteam0'
    rails_user.save(validate: false)
    facade_user = User.authenticate username: 'asarteam0', password: 'scareface'
    auth_proxy = facade_user.auth_proxy
    assert auth_proxy.authorized?
    entry_hash = {
        :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :facade_user => facade_user
    }

    sport_session = Facade::SportSession.create(entry_hash)
    assert auth_proxy.save(sport_session)

    rails_sport_session = ::SportSession.find_by type: 'Running'
    pp rails_sport_session.cybercoach_uri

  end



  test "if creating a new object succeeds using new" do

    rails_user = ::User.new name: 'asarteam0'
    rails_user.save(validate: false)

    facade_user = Facade::User.authenticate username: 'asarteam0', password: 'scareface'
    auth_proxy = facade_user.auth_proxy
    assert auth_proxy.authorized?
    cc_user = facade_user.cc_user
    subscription = RestAdapter::Models::Subscription.retrieve sport: 'Running', user: cc_user
    assert subscription
    entry_hash = {
        :type =>  RestAdapter::Models::Entry::Type::Running,
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :public_visible => RestAdapter::Privacy::Public,
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :subscription => subscription
    }
    cc_entry = RestAdapter::Models::Entry.new entry_hash


    hash = {
        rails_sport_session: ::SportSession.new(user_id: rails_user.id),
        type: 'Running',
        cc_entry: cc_entry
    }

    sport_session = Facade::SportSession.new(hash)
    assert auth_proxy.save(sport_session)

  end

end