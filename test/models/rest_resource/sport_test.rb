require 'test_helper'
require 'pp'


class SportTest < ActiveSupport::TestCase

  test "list all sport categories" do
    sport_categories = CyberCoachSport.all
    # and get all details
    sport_categories =  sport_categories.map {|s| s.load}
  end

  test "find sport category" do
    sport_category = CyberCoachSport.find_first filter: ->(s) {s.name == 'Boxing'}
    assert_equal 'Boxing', sport_category.name
    assert_not_empty sport_category.uri
  end

  test "find sport category and load details" do
    sport_category = CyberCoachSport.find_first filter: ->(s) {s.name == 'Boxing'}
    sport_category = sport_category.load
    assert_equal 'Boxing', sport_category.name
    assert_not_empty sport_category.description
    assert_not_empty sport_category.uri
  end

end