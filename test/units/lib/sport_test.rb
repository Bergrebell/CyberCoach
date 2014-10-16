require 'test_helper'
require 'pp'
class TestSportAdapter  < ActiveSupport::TestCase

  test "get all sport categories" do
    sports = RestAdapter::Sport.all
    assert_not_nil sports
  end

  test "retrieve sport category" do
    sport = RestAdapter::Sport.retrieve 'Soccer'
    assert_not_nil sport
    assert_equal 'Soccer', sport.name
  end

end