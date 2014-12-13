require 'test_helper'
require 'ostruct'

class TestTimeline < MiniTest::Test

  def setup
    friends = [
        OpenStruct.new(id: 2, username: "Alex1", created_at: DateTime.now),
        OpenStruct.new(id: 3, username: "Alex2", created_at: DateTime.now)
    ]

    sport_sessions = [
        OpenStruct.new(title: "sportsession boxing", type: "boxing", created_at: DateTime.now),
        OpenStruct.new(title: "sportsession running", type: "running", created_at: DateTime.now)
    ]

    achievements = [
        OpenStruct.new(sport: "running", description: "great shape", created_at: DateTime.now)
    ]

    @a_user = OpenStruct.new(friends: friends, sport_sessions: sport_sessions, achievements: achievements)
  end

  def test_should_get_items
    items = Timeline.items(@a_user)
    assert items
    items.each do |item|
      assert item.partial
      assert item.created_at
    end
  end

end