require 'test_helper'
require 'pp'

# Some prototype test classes
class MyAchievement

  attr_reader :id, :title, :points, :sport, :attributes

  def initialize(params)
    @id = params[:id]
    @title = params[:title]
    @points = params[:points]
    @sport = params[:sport]
    @attributes = params[:attributes]
  end

end

class GameRule

  attr_reader :achievements

  def initialize(params)
    @validator = params[:validator]
    @achievements = Array.new
    # hack alert
    # add multiple achievements if :achievements is used
    @achievements.push(*params[:achievements]) if not params[:achievements].nil?
    # add single achievement if :achievement is used
    @achievements << params[:achievement] if not params[:achievement].nil?
  end

  def validate(data)
    @validator.call(data)
  end

  # checks if a rule can be applied on the provided attributes and the corresponding sport category
  def applicable?(params)
    # get all attributes in the data
    data_attributes = Set.new params[:attributes].keys # just get the keys and create a set of keys

    # get all necessary attributes for an achievement / multiple achievements
    achievement_attributes = @achievements.map {|a| a.attributes}.flatten
    achievement_attributes = Set.new achievement_attributes # create a set of attributes (eliminates duplicated attributes)


    # create a set of sport categories, first extract sport category and the resulting list to Set.new
    sports = Set.new @achievements.map { |a| a.sport }

    # check if set of achievement attributes is a subset of the set data attributes
    # if so the rule can be applied = all necessary attributes are matched / available
    # and check if the rule is responsible for this sport category.

    achievement_attributes.subset?(data_attributes) and  sports.include?(params[:sport]) #hack alert: include?
  end

end

class GameController

  def initialize(params)
    @rules = params[:rules]
  end

  # Check user and some attributes.
  #
  def check(params)
    user = params[:user]
    attributes = params[:attributes]
    achievements = Array.new # use temp array, because some rules might use the user achievements,
    @rules.each do |rule|
      # check if the rule can be applied on these parameters
      if rule.applicable?(params)
        params[:attributes][:user] = user # dirty hack, not really nice, otherwise the game rules don't have access to
        # the user object
        if rule.validate(params[:attributes])
          achievements.push(*rule.achievements)
        end
      end
    end

    achievements.each do |achievement|
      user.achievements << achievement
    end
    achievements
  end

end

class TestUser

  attr_accessor :achievements

  def initialize
    @achievements = Set.new
  end

  def has_achievement?(achievement)
    @achievements.include?(achievement)
  end

end

class TestAchievement  < ActiveSupport::TestCase


  test "interaction example " do

    # create some achievements and use the title as key values for readability
    achievements = {
        '5 km in 30 minutes' => MyAchievement.new({id: 1, title: '5 km in 30 minutes',
                                                   attributes: [:distance, :duration], points: 30, sport: 'Running'}),

        '10 km in 60 minutes' => MyAchievement.new({id: 2, title: '10 km in 60 minutes',
                                                    attributes: [:distance, :duration], points: 60, sport: 'Running'}),

        '10 km' => MyAchievement.new({id: 3, title: '10 km run achieved',
                                                    attributes: [:distance], points: 60, sport: 'Running'}),

        'first run' => MyAchievement.new({id: 4, title: 'First run! Congrats Buddy!',
                                                    attributes: [:distance], points: 60, sport: 'Running'}),

        '5 km' => MyAchievement.new({id: 3, title: '5 km run achieved',
                                                    attributes: [:distance], points: 60, sport: 'Running'}),
    }

    # create rules and associate them with the corresponding achievements
    rule_1 = GameRule.new({ achievement: achievements['5 km in 30 minutes'],
                            validator: ->(attributes) { (attributes[:distance] >= 5 and attributes[:duration] <= 30) }
                        })

    # special rule: links two achievements together:
    # if a user achieves 10km in 60 minutes, he is also awarded for 5km in 30 minutes
    rule_2 = GameRule.new({ achievements: [achievements['10 km in 60 minutes'],achievements['5 km in 30 minutes']],
                            validator: ->(attributes) { attributes[:distance] >= 10 and attributes[:duration] <= 60}
                          })
    rule_3 = GameRule.new({ achievement: achievements['10 km'],
                            validator: ->(attributes) { attributes[:distance] >= 10}
                          })

    rule_4 = GameRule.new({ achievement: achievements['first run'],
                            validator: ->(attributes) { attributes[:distance] >= 0 and
                                  not attributes[:user].has_achievement?(achievements['first run']) }
                          })

    rule_5 = GameRule.new({ achievement: achievements['5 km'],
                            validator: ->(attributes) { attributes[:distance] >= 5 }
                          })

    # inject some rules into the game controller
    game_controller = GameController.new rules: [rule_1, rule_2, rule_3, rule_4, rule_5]

    # give the user an achievement
    user = TestUser.new
    user.achievements << achievements['first run']

    # user enters new data see :attributes and :sport
    obtained_achievements = game_controller.check user: user, attributes: { distance: 11, duration:55 }, sport: 'Running'

    assert obtained_achievements.include?(achievements['10 km in 60 minutes'])
    assert obtained_achievements.include?(achievements['10 km'])
    assert obtained_achievements.include?(achievements['5 km'])
    assert obtained_achievements.include?(achievements['5 km in 30 minutes'])
    assert !obtained_achievements.include?(achievements['first run'])



  end

end
