require 'test_helper'
#require 'pp'

require 'rubygems'
require 'json'

# Some prototype test classes
class MyAchievement

  attr_reader :id, :title, :points, :sport, :attributes, :rule_definition_id

  def initialize(params) # using hashes as parameters, we can simulate named parameters using a cool notation like
    @id = params[:id]    # blah. new :first 'x', :second 'y' etc
    @title = params[:title]
    @points = params[:points]
    @sport = params[:sport]
    @attributes = params[:attributes]
    @rule_definition_id = params[:rule_definition_id]
  end

end


class RuleDefinition

  attr_reader :id, :rule_id, :data

  def initialize(params)
    @id = params[:id]
    @rule_id = params[:rule_id] # Rule responsible to evaluate data
    @data = JSON.parse(params[:data])
  end

end


class Running
  attr_reader :duration, :distance, :user

  def initialize(params)
    @duration = params[:duration]
    @distance = params[:distance]
    @user = params[:user]
  end

end


class Rule

  attr_reader :rule_definition, :user

  def initialize(params)
    @sport = params[:sport]
    @rule_definition = params[:rule_definition]
    @user = params[:user]
  end

  def check
    false
  end

end

class AttributeRule < Rule

  def check
    @rule_definition.data.each do |data|
      op = data['operator']
      value = data['value']
      attr = data['attribute']
      result = false
      if op == '>='
        result = @sport.send(attr).to_f >= value.to_f
        print "checking if " + @sport.send(attr).to_f.to_s + " >= " + value.to_f.to_s
      elsif op == '<='
        result = (@sport.send(attr).to_f <= value.to_f)
      elsif op == '='
        result = (@sport.send(attr).to_f == value.to_f)
      end
      print result
      # Assuming multiple conditions are AND connected
      return false unless result
    end

    true

  end

end


class TestUser

  attr_accessor :achievements

  def initialize
    @achievements = Set.new #use set to eliminate duplicates
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
                                                   rule_definition_id: 1, points: 30, sport: 'Running'}),

        '10 km in 60 minutes' => MyAchievement.new({id: 2, title: '10 km in 60 minutes',
                                                    rule_definition_id: 2, points: 60, sport: 'Running'}),

        'first run' => MyAchievement.new({id: 4, title: 'First run! Congrats Buddy!',
                                          attributes: [:distance], points: 60, sport: 'Running'}),
    }

    # Create some rule definitions
    rule_def_1 = RuleDefinition.new({rule_id: 1, data: '[{"attribute" : "distance", "operator" : ">=", "value" : "5"}, {"attribute" : "duration", "operator" : "<=", "value" : "30"}]'})

    user = TestUser.new


    # Create a running event
    running_session = Running.new({duration: 29, distance: 5, user: user})

    rule = AttributeRule.new({sport: running_session, rule_definition: rule_def_1, user: user})


    # This would be done by the Achievement controller when looping all the achievements not yet obtained
    print rule.check
    if rule.check
      user.achievements << achievements['5 km in 30 minutes']
    end

    assert user.achievements.include?(achievements['5 km in 30 minutes'])

  end

end