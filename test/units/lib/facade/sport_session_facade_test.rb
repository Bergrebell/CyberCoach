require 'test_helper'
require 'pp'
class TestSportSessionFacade < ActiveSupport::TestCase


  test "if creating a new sport session succeeds using create" do

    rails_user = ::User.new name: 'asarteam0'
    rails_user.save(validate: false)
    facade_user = Facade::User.authenticate username: 'asarteam0', password: 'scareface'
    auth_proxy = facade_user.auth_proxy

    assert_not_nil auth_proxy
    assert auth_proxy.authorized?

    entry_hash = {
        :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }

    sport_session = Facade::SportSession.create(entry_hash)
    entry_uri = sport_session.save
    assert entry_uri
    pp entry_uri

    rails_sport_session = ::SportSession.find_by type: 'Running'
    pp rails_sport_session.cybercoach_uri

  end


  test "if updating a new sport session succeeds" do

    rails_user = ::User.new name: 'asarteam0'
    rails_user.save(validate: false)
    facade_user = Facade::User.authenticate username: 'asarteam0', password: 'scareface'
    auth_proxy = facade_user.auth_proxy

    assert_not_nil auth_proxy
    assert auth_proxy.authorized?

    entry_hash = {
        :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }

    sport_session = Facade::SportSession.create(entry_hash)
    entry_uri = sport_session.save
    assert entry_uri
    pp entry_uri

    facade_sport_session = Facade::SportSession.find_by cybercoach_uri: entry_uri
    assert_not_nil facade_sport_session
    assert facade_sport_session.is_a?(Facade::SportSession)

    new_values = {
        :type =>  'Running',
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Zuerich',
        :comment => 'Updated Some comment',
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :user => facade_user
    }
    result = facade_sport_session.update(new_values)
    assert_equal true, result
  end


  test "if creating a new object succeeds using new" do

    rails_user = ::User.new name: 'asarteam0'
    rails_user.save(validate: false)

    facade_user = Facade::User.authenticate username: 'asarteam0', password: 'scareface'
    auth_proxy = facade_user.auth_proxy
    assert_not_nil auth_proxy
    assert auth_proxy.authorized?
    assert_not_nil facade_user.cc_model #its our cc_user

    cc_user = facade_user.cc_model

    subscription = RestAdapter::Models::Subscription.retrieve sport: 'Running', user: cc_user

    assert_not_nil subscription

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
        cc_entry: cc_entry,
        auth_proxy: auth_proxy
    }

    sport_session = Facade::SportSession.new(hash)
    entry_uri = sport_session.save
    assert entry_uri
    pp entry_uri
  end

end