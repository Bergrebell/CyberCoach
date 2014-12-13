class Timeline

  class Item
    def initialize(object)
      @object = object
    end

    def object
      @object
    end

    def time
      created = object.created_at
      dt = created.to_datetime
      dt.strftime"%Y %m %d, %H:%M"
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

    def user
      object
    end
  end

  class SportSessionItem < Item
    def partial
      "welcome/sport_session"
    end

    def type
      object.type
    end

    def title
      object.title
    end

    def location
      object.location
    end

  end

  class AchievementItem < Item
    def partial
      "welcome/achievement"
    end

    def sport
      object.sport
    end

    def description
      object.description
    end

    def icon
      object.icon
    end

    def title
      object.title
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