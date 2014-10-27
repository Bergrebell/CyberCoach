require 'pp'
class TestPartnershipAdapter  < ActiveSupport::TestCase

  test "get all partnerships" do
    partnerships = RestAdapter::Models::Partnership.all
    assert_not_nil partnerships
    assert partnerships.size > 0
  end


  test "id of a partnership" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    timon = RestAdapter::Models::User.retrieve 'timon'

    partnership = RestAdapter::Models::Partnership.new first_user: mike, second_user: timon
    assert_equal 'mikeshiva;timon', partnership.id
  end

  test "mike shiva proposes a partnership to timon" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    timon = RestAdapter::Models::User.retrieve 'timon'

    # create auth proxy for mike
    auth_proxy = RestAdapter::AuthProxy.new username: 'mikeShiva', password: '12345'
    assert auth_proxy.authorized?

    # create a partnership
    partnership = RestAdapter::Models::Partnership.new(
        first_user: mike,
        second_user: timon,
        public_visible: RestAdapter::Privacy::Public
    )

    assert auth_proxy.save(partnership)

    test_partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'

    assert_not_nil test_partnership

    assert test_partnership.confirmed_by?(mike)
    assert test_partnership.confirmed_by?(timon) == false

  end


  test "retrieve partnerships over user object" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    partnerships = mike.partnerships
    pp mike
    pp partnerships
    assert_not_nil partnerships
    assert partnerships.size > 0
    partnership = partnerships.first
    assert partnership.confirmed_by?('timon') == false
    pp partnership
  end



  test "find mikeshiva's partnership" do
    results = RestAdapter::Models::Partnership.all filter: ->(p) { p.associated_with?('mikeshiva') and p.associated_with?('timon')}
    assert_not_nil results
    assert results.size > 0
    partnership = results.first

    assert partnership.confirmed_by?('mikeshiva')
    pp partnership
    assert partnership.confirmed_by?('timon')
  end


  test "timon confirms partnership to mike shiva" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    timon = RestAdapter::Models::User.retrieve 'timon'

    # create auth proxy for timon
    auth_proxy = RestAdapter::AuthProxy.new username: 'timon', password: 'scareface'
    assert auth_proxy.authorized?

    # create a partnership
    partnership = RestAdapter::Models::Partnership.new(
        first_user: mike,
        second_user: timon,
        public_visible: RestAdapter::Privacy::Public
    )

    assert auth_proxy.save(partnership)

    test_partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'

    assert_not_nil test_partnership

    assert test_partnership.confirmed_by?(mike)
    assert test_partnership.confirmed_by?(timon)
  end


  test "however, timon does not like mike shiva so he leaves the partnership" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    timon = RestAdapter::Models::User.retrieve 'timon'

    # create auth proxy for timon
    auth_proxy = RestAdapter::AuthProxy.new username: 'timon', password: 'scareface'
    assert auth_proxy.authorized?

    # get the partnership
    partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'

    assert auth_proxy.delete(partnership)

    test_partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'
    assert_not_nil test_partnership

    assert test_partnership.confirmed_by?(mike)
    assert test_partnership.confirmed_by?(timon) == false
  end



  test "mike shiva is so sad that he wants to forget timon, so he also leaves the partnership" do
    mike = RestAdapter::Models::User.retrieve 'mikeShiva'
    timon = RestAdapter::Models::User.retrieve 'timon'

    # create auth proxy for timon
    auth_proxy = RestAdapter::AuthProxy.new username: 'mikeShiva', password: '12345'
    assert auth_proxy.authorized?

    # get the partnership
    partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'

    assert auth_proxy.delete(partnership)

    test_partnership = RestAdapter::Models::Partnership.retrieve 'mikeshiva;timon'
    assert test_partnership == false

  end


  test "get a partnership" do
    # first possibility
    partnership = RestAdapter::Models::Partnership.retrieve 'alex;timon'
    assert_not_nil partnership
    assert partnership.id.is_a?(String)

    # second possibility
    partnership = RestAdapter::Models::Partnership.retrieve first_user: 'alex', second_user: 'timon'
    assert_not_nil partnership

    # third possibility
    alex = RestAdapter::Models::User.retrieve 'alex'
    timon = RestAdapter::Models::User.retrieve 'timon'
    partnership = RestAdapter::Models::Partnership.retrieve first_user: alex, second_user: timon
    assert_not_nil partnership
  end


  test "filter partnerships" do
    alex = RestAdapter::Models::User.retrieve 'alex'
    partnerships = RestAdapter::Models::Partnership.all filter: -> (partnership) {partnership.associated_with?(alex)}
    assert_not_nil partnerships
    assert partnerships.size > 0
  end


end