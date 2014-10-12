require 'test_helper'
require 'pp'


class PartnershipTest < ActiveSupport::TestCase

  test "serializable properties" do
    assert_not_nil CyberCoachPartnership.serializable_properties
  end

  test "resource uri" do
    assert_equal '/partnerships', CyberCoachPartnership.resource_path
    assert_equal 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/partnerships', CyberCoachPartnership.collection_resource_uri

  end

  test "get partnerships" do
    partnerships = CyberCoachPartnership.all query: { start: 0, size: 5 }
  end

  test "find partnership" do
    partnership = CyberCoachPartnership.find with: 'lexruee5', and: 'lexruee11'
    assert_equal 'lexruee5', partnership.first_user.username
    assert_equal 'lexruee11', partnership.second_user.username

  end

  test "partnership confirmation" do
    partnership = CyberCoachPartnership.find with: 'lexruee5', and: 'lexruee11'
    user = CyberCoachUser.find_first(filter: ->(user) {user.username == 'lexruee5'})

    # both works, just pass a user object or a username string
    assert partnership.confirmed_by?(user)
    assert partnership.confirmed_by?('lexruee11')

    assert partnership.confirmed_by_first_user?
    assert partnership.confirmed_by_second_user?
  end


  test "propose partnership" do
    alex = CyberCoachUser.find_first(filter: ->(user) { user.username = 'alex'})
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username = 'timon'})

    assert_not_nil alex
    assert_not_nil timon

    assert alex.proposes_partnership(to: timon, username: 'alex', password: 'scareface', publicvisible: RestResource::Privacy::Public) !=false
    assert timon.confirms_partnership(to: alex, username: 'timon', password: 'scareface', publicvisible: RestResource::Privacy::Public) !=false
  end


  test "moritz proposed partnership to timon" do
    moritz = CyberCoachUser.find_first(filter: ->(user) { user.username == 'moritz'})
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username == 'timon'})

    partnership = CyberCoachPartnership.new user1: moritz, user2: timon, publicvisible: RestResource::Privacy::Public
    assert partnership.first_user == moritz
    assert partnership.first_user != timon
    assert partnership.second_user == timon
    assert partnership.second_user != moritz

    assert partnership.save(username: 'moritz', password: 'scareface') != false
  end

  test "timon confirms partnership to moritz" do
    moritz = CyberCoachUser.find_first(filter: ->(user) { user.username == 'moritz'})
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username == 'timon'})

    partnership = CyberCoachPartnership.new user1: moritz, user2: timon, publicvisible: RestResource::Privacy::Public

    assert partnership.save(username: 'timon', password: 'scareface') != false
  end

  test "get partnerships of a user" do
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username == 'timon'})

    partnerships = timon.partnerships
    assert partnerships!=false
    pp partnerships
  end


  test "update partnerships of a user" do
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username == 'timon'})

    partnerships = timon.partnerships
    assert partnerships!=false
    partnerships.each do |p|
      p.publicvisible = RestResource::Privacy::Member
      assert p.update(username: 'timon', password: 'scareface')
    end

    partnerships = timon.partnerships
    assert partnerships!=false
    partnerships.each do |p|
      assert p.publicvisible == RestResource::Privacy::Member
      p.publicvisible = RestResource::Privacy::Public
      assert p.update(username: 'timon', password: 'scareface')
    end
  end


  test "delete partnerships of a user" do
    timon = CyberCoachUser.find_first(filter: ->(user) { user.username == 'timon'})

    partnerships = timon.partnerships
    assert partnerships!=false
    partnerships.each do |p|
      p = p.delete(username: 'timon', password: 'scareface')
      assert p.confirmed_by?(timon) == false
    end

  end


end