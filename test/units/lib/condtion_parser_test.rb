require 'test_helper'
require 'pp'
class TestConditionParser  < ActiveSupport::TestCase

  test "and example" do
    parser =  ConditionParser.new

    # json string
    conditions = [
            { value: 10, op: "<", attribute: "km"},
             "and", { value: 20, op: ">", attribute: "km"}
    ]

    # value must be between 10 and 20

    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 16})
    assert validator.call

    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 15})
    assert validator.call
  end

  test "or example" do
    # json string
    conditions = [
        { value: 10, op: "=", attribute: "km"},
        "or", { value: 20, op: "=", attribute: "km"},
    ]

    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 10})
    assert validator.call

    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 20})
    assert validator.call
  end

  test "second and example" do
    # json string
    conditions = [
        { value: 10, op: "<=", attribute: "km"},
        "and", { value: 60, op: ">=", attribute: "duration"},
    ]

    # km must be greater than or equals to 10 km
    # duration must be less or equals to 60

    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 11, duration: 55})
    assert validator.call

    # should fail
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 9, duration: 55})
    assert !validator.call
  end



  test "second or example" do
    # json string
    conditions = [
        { value: 10, op: "<=", attribute: "km"},
        "or", { value: 60, op: ">=", attribute: "duration"},
    ]

    # km must be greater than or equals to 10 km
    # duration must be less or equals to 60

    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 9, duration: 55})
    assert validator.call

    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 11, duration: 61})
    assert validator.call

    # should fail
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 9, duration: 61})
    assert !validator.call
  end


  test "not example" do
    # json string
    conditions = [
        { value: 10, op: "!=", attribute: "km"}
    ]


    # should fail
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 10})
    assert !validator.call

    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 20})
    assert validator.call
  end

end