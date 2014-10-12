require 'test_helper'

class TestConditionParser  < ActiveSupport::TestCase


  test "includes example" do
    # json string
    conditions = [
        { value: [5,10,15,30], op: "includes", attribute: "km"}
    ]
    # km attribute must be a member of [5,10,15,30]

    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 10})
    assert validator.call
  end


  test "excludes example" do
    # json string
    conditions = [
        { value: [5,10,15,30], op: "excludes", attribute: "km"}
    ]
    # km attribute must not be a member of [5,10,15,30]

    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 10})
    assert !validator.call #should fail
  end


  test "and example" do
    # json string
    conditions = [
            { value: 10, op: "<", attribute: "km"},
             "and", { value: 20, op: ">", attribute: "km"}
    ]
    # km attribute must be between 10 and 20

    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 16})
    assert validator.call

    validator = parser.parse(conditions: conditions, assignments: { km: 15})
    assert validator.call
  end


  test "or example" do
    # json string
    conditions = [
        { value: 10, op: "=", attribute: "km"},
        "or", { value: 20, op: "=", attribute: "km"},
    ]
    # km attribute must equals to 10 or 20

    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 10})
    assert validator.call

    validator = parser.parse(conditions: conditions, assignments: { km: 20})
    assert validator.call
  end


  test "second and example" do
    # json string
    conditions = [
        { value: 10, op: "<=", attribute: "km"},
        "and", { value: 60, op: ">=", attribute: "duration"},
    ]

    # km attribute must be greater than or equals to 10 km AND
    # duration attribute must be less or equals to 60

    # should succeed
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 11, duration: 55})
    assert validator.call

    # should fail
    validator = parser.parse(conditions: conditions, assignments: { km: 9, duration: 55})
    assert !validator.call
  end


  test "second or example" do
    # json string
    conditions = [
        { value: 10, op: "<=", attribute: "km"},
        "or", { value: 60, op: ">=", attribute: "duration"},
    ]

    # km attribute must be greater than or equals to 10 km OR
    # duration attribute must be less or equals to 60

    # should succeed
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 9, duration: 55})
    assert validator.call

    # should succeed
    validator = parser.parse(conditions: conditions, assignments: { km: 11, duration: 61})
    assert validator.call

    # should fail
    validator = parser.parse(conditions: conditions, assignments: { km: 9, duration: 61})
    assert !validator.call
  end


  test "not example" do
    # json string
    conditions = [
        { value: 10, op: "!=", attribute: "km"}
    ]


    # should fail
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 10})
    assert !validator.call

    # should succeed
    validator = parser.parse(conditions: conditions, assignments: { km: 20})
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
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions, assignments: { km: 10})
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
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions,
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
    parser =  ConditionParser.new
    validator = parser.parse(conditions: conditions,
                                          assignments: { v1: 10, v2: 8, v3: 9, v4: 6, v5: 5, v6: 5, v7: 4})
    assert validator.call
  end


end