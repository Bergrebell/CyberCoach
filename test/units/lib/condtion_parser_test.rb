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

    # km must be greater than or equals to 10 km AND
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

    # km must be greater than or equals to 10 km OR
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

  test "second not example" do
    # json string
    # !(km!=10)
    conditions = [
        "not",
        { value: 10, op: "!=", attribute: "km"}
    ]


    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions, assignments: { km: 10})
    assert validator.call

  end

  test "complex example" do
    # json string
    # (10!= v1 && 9!= v2 && 8!= v3 && 7!= v4) || (7!= v5 && 4!= v6 && 3!= v7)
    conditions = [
        "(",
        { value: 10, op: "!=", attribute: "v1"},
        "and",
        { value: 9, op: "!=", attribute: "v2"},
        "and",
        { value: 8, op: "!=", attribute: "v3"},
        "and",
        { value: 7, op: "!=", attribute: "v4"},
        ")",
        "or",
        "(",
        { value: 5, op: "!=", attribute: "v5"},
        "and",
        { value: 4, op: "!=", attribute: "v6"},
        "and",
        { value: 3, op: "!=", attribute: "v7"},
        ")"
    ]

      # should fail
      validator = ConditionParser.new.parse(conditions: conditions,
                                            assignments: { v1: 10, v2: 8, v3: 9, v4: 6, v5: 5, v6: 5, v7: 4})
      assert !validator.call
  end

  test "second complex example" do
    # json string
    # (!(10!= v1) && 9!= v2 && 8!= v3 && 7!= v4) || ( !(7!= v5) && 4!= v6 && 3!= v7)
    conditions = [
        "(",
        "not",
        { value: 10, op: "!=", attribute: "v1"},
        "and",
        { value: 9, op: "!=", attribute: "v2"},
        "and",
        { value: 8, op: "!=", attribute: "v3"},
        "and",
        { value: 7, op: "!=", attribute: "v4"},
        ")",
        "or",
        "(",
        "not",
        { value: 5, op: "!=", attribute: "v5"},
        "and",
        { value: 4, op: "!=", attribute: "v6"},
        "and",
        { value: 3, op: "!=", attribute: "v7"},
        ")"
    ]

    # should succeed
    validator = ConditionParser.new.parse(conditions: conditions,
                                          assignments: { v1: 10, v2: 8, v3: 9, v4: 6, v5: 5, v6: 5, v7: 4})
    assert validator.call
  end
end