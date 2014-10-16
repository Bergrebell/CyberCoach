require 'test_helper'
require 'pp'
class TestPartnershipAdapter  < ActiveSupport::TestCase

  test "get all partnerships" do
    partnerships = RestAdapter::Partnership.all
    assert_not_nil partnerships
    assert partnerships.size > 0
  end

  test "id of a partnership" do
    moritz = RestAdapter::User.retrieve 'moritz'
    timon = RestAdapter::User.retrieve 'timon'

    partnership = RestAdapter::Partnership.new first_user: moritz, second_user: timon
    assert_equal 'moritz;timon', partnership.id
  end

  test "uri of a partnership" do
    moritz = RestAdapter::User.retrieve 'moritz'
    timon = RestAdapter::User.retrieve 'timon'
    pp moritz
    pp timon


    partnership = RestAdapter::Partnership.new first_user: moritz, second_user: timon
    pp partnership
    assert_equal '/CyberCoachServer/resources/partnerships/moritz;timon', partnership.uri
  end

  test "get a partnership" do
    partnership = RestAdapter::Partnership.retrieve 'alex;timon'
    assert_not_nil partnership
    pp partnership
  end

  test "filter partnerships" do
    alex = RestAdapter::User.retrieve 'alex'
    partnerships = RestAdapter::Partnership.all filter: -> (partnership) {partnership.associated_with?(alex)}
    assert_not_nil partnerships
    assert partnerships.size > 0
  end


end