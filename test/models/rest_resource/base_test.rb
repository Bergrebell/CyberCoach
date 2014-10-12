require 'test_helper'

class TestCyberCoachUser < RestResource::Base

  id :username

  properties :username, :password, :email, :publicvisible

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'

  resource_path '/users/'

  format :xml

end


class TestCyberCoachUser2 < RestResource::Base

  id :username

  properties :username, :password, :email, :publicvisible
  serializable :username, :email, :publicvisible

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'

  resource_path '/users/'

  format :xml

end

class TestCyberCoachUser3 < RestResource::Base

  id :username

  properties :username, :password, :email, :publicvisible
  serializable :none

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'

  resource_path '/users/'

  format :xml

end

class RestResource::BaseTest < ActiveSupport::TestCase


  test "registered properties " do
    [:username,:password,:email,:publicvisible].each do |property|
      assert TestCyberCoachUser.registered_properties.include?(property)
      assert TestCyberCoachUser.serializable_properties.include?(property)
    end
  end

  test "serializable properties" do
    [:username,:email,:publicvisible].each do |property|
      assert TestCyberCoachUser2.serializable_properties.include?(property)
    end
    assert TestCyberCoachUser2.serializable_properties.exclude?(:password)
  end

  test "none serializable properties" do
    [:username,:email,:publicvisible].each do |property|
      assert TestCyberCoachUser3.serializable_properties.exclude?(property)
    end
  end

  test "test id" do
    assert_equal(:username,TestCyberCoachUser.id)
  end

  test "test resource uri" do
    should_be =  'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users'
    assert_equal(should_be,TestCyberCoachUser.collection_resource_uri)
  end

  test "test format" do
    should_be = :xml
    assert_equal(should_be,TestCyberCoachUser.format)
  end

  test "base url" do
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'
    assert_equal(should_be,TestCyberCoachUser.base_uri)
  end

  test "resource path" do
    should_be = '/users'
    assert_equal(should_be,TestCyberCoachUser.resource_path)
  end

  test "create empty test user" do
    empty_user = TestCyberCoachUser.new
  end


  test "create test user" do
    user = TestCyberCoachUser.new username: 'lexruee', password: 'hidden'
    puts user.properties
    assert_equal('lexruee',user.username)
    assert_equal('hidden',user.password)
  end

  test "test getter methods" do
    empty_user = TestCyberCoachUser.new
    [:username,:password, :email, :publicvisible].each do |property|
      assert_nil empty_user.send property
    end
  end

  test "test setter methods" do
    empty_user = TestCyberCoachUser.new
    [:username=,:password=, :email=, :publicvisible=].each do |property|
      assert_not_nil empty_user.send property, 'some value'
    end
  end

end
