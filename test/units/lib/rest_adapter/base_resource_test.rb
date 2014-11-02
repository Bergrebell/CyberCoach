require 'pp'
class TestResource  < ActiveSupport::TestCase

  test "base resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::Models::BaseResource.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::Models::BaseResource.site
    assert_equal :json, RestAdapter::Models::BaseResource.deserialize_format
    assert_equal :xml, RestAdapter::Models::BaseResource.serialize_format

    assert_equal :json, RestAdapter::Models::User.deserialize_format
    assert_equal :xml, RestAdapter::Models::User.serialize_format
  end


  test "deseralize user" do
    user = RestAdapter::Models::User.retrieve 'asarteam0'
    assert_not_nil user.username
    assert_not_nil user.partnerships
    assert_not_nil user.real_name
    assert_nil user.password
  end

  test "serialize user" do
    user = RestAdapter::Models::User.new(email: 'alex', password: 'dsfdsf',
                                 partnerships: [], real_name: 'Alex',
                                 public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    pp xml
    hash = Hash.from_xml(xml)
    assert_not_nil hash['user']
    assert hash['user'].keys.reduce { |acc,key| acc &&= ['password','email', 'publicvisible','realname'].include?(key) }
    assert hash['user'].reduce {|acc,(key,value)| acc &&= !value.nil? }
  end

  test "serialize should ignore nil values" do
    user = RestAdapter::Models::User.new(email: nil, password: nil,
                                 partnerships: [], real_name: 'Alex',
                                 public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    hash = Hash.from_xml(xml)
    pp xml
    assert_nil hash['user']['email']
    assert_nil hash['user']['password']
    assert_equal 'Alex', hash['user']['realname']
  end

  test "serialize should ignore empty strings" do
    user = RestAdapter::Models::User.new(email: nil, password: '',
                                 partnerships: [], real_name: '',
                                 public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    hash = user.as_hash
    pp hash
    pp xml

  end


  test "serialize should ignore * password " do
    user = RestAdapter::Models::User.new(email: nil, password: '*',
                                 partnerships: [], real_name: '',
                                 public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    hash = user.as_hash
    pp xml

  end


  test "serialize partnership" do
    user = RestAdapter::Models::Partnership.new(public_visible: RestAdapter::Privacy::Public)
    xml = user.serialize
    pp xml
    hash = Hash.from_xml(xml)
    assert_not_nil hash['partnership']
    assert hash['partnership'].keys.include?('publicvisible')
  end

end