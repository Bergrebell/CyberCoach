class Timeline

  class Item
    def initialize(object)
      @object = object
    end

    def self.items
    end

    def created_at
      @object.created_at
    end

    def partial
      raise "Not implemented!"
    end
  end

  class FriendItem < Item
    def partial
      "welcome/friend"
    end
  end

  class SportSessionItem < Item
    def partial
      "welcome/sport_session"
    end
  end

  class AchievementItem < Item
    def partial
      "welcome/achievement"
    end
  end

  def self.items(a_user)
    id = a_user.id
    achievements = a_user.achievements.map {|a| AchievementItem.new(a)}
    friends = a_user.friends.map {|a| FriendItem.new(a)}
    sport_sessions = a_user.sport_sessions.map {|a| SportSessionItem.new(a)}
    items = achievements + friends + sport_sessions
    items.sort_by(&:created_at)
  end
end