require 'pp'
class TestResource  < ActiveSupport::TestCase

  test "validation should succeed" do
    user = RestAdapter::User.new username: 'alex', password: 'dsfdsf', partnerships: []
    assert user.validate(:password)
  end


  test "validation should fail" do
    user = RestAdapter::User.new username: 'alex', password: '', partnerships: []
    assert !user.validate(:password)
    user = RestAdapter::User.new username: 'alex', password: nil, partnerships: []
    assert !user.validate(:password)

    user = RestAdapter::User.new username: 'alex', password: nil, partnerships: []
    assert !user.validate(:public_visible)
  end

  test "valid? should succeed" do
    user = RestAdapter::User.new username: 'alex', password: 'test', public_visible: RestAdapter::Privacy::Public
    assert user.valid?
  end

  test "valid? should fail" do
    user = RestAdapter::User.new username: 'alex', password: nil, partnerships: []
    assert !user.valid?

    user = RestAdapter::User.new username: '', password: nil, partnerships: []
    assert !user.valid?

    user = RestAdapter::User.new username: nil, password: nil, partnerships: []
    assert !user.valid?

  end

  test "serialize user" do
    user = RestAdapter::User.new(email: 'alex', password: 'dsfdsf',
                                 partnerships: [], real_name: 'Alex',
                                 public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    pp xml
    hash = Hash.from_xml(xml)
    assert_not_nil hash['user']
    assert hash['user'].keys.reduce { |acc,key| acc &&= ['password','email', 'publicvisible','realname'].include?(key) }
    assert hash['user'].reduce {|acc,(key,value)| acc &&= !value.nil? }
  end


  test "serialize partnership" do
    user = RestAdapter::Partnership.new(public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    pp xml
    hash = Hash.from_xml(xml)
    assert_not_nil hash['partnership']
    assert hash['partnership'].keys.include?('publicvisible')
  end

end