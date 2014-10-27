require 'pp'
class TestSportAdapter  < ActiveSupport::TestCase

  test "get all sport categories" do
    sports = RestAdapter::Models::Sport.all
    assert_not_nil sports
  end

  test "retrieve sport category" do
    sport = RestAdapter::Models::Sport.retrieve 'Soccer'
    assert_not_nil sport
    assert_equal 'Soccer', sport.name
  end


  test "fetch sport category" do
    sport = RestAdapter::Models::Sport.retrieve 'Soccer'
    sport = sport.fetch
    assert_not_nil sport
    assert_equal 'Soccer', sport.name
    assert_not_nil sport.description
  end

  test "lazy loading on description" do
    sports = RestAdapter::Models::Sport.all
    sports.each do |sport|
      assert_not_nil sport.description
    end
  end

end