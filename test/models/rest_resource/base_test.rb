require 'test_helper'

class CyberCoachUser < RestResource::Base

  id :username

  properties :username, :password, :email, :publicvisible

  base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'

  resource_path '/users/'

  format :xml

end

class RestResource::BaseTest < ActiveSupport::TestCase

  test "test id" do
    assert_equal(:username,CyberCoachUser.id)
  end

  test "test resource uri" do
    should_be =  'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users'
    assert_equal(should_be,CyberCoachUser.resource_uri)
  end

  test "test format" do
    should_be = :xml
    assert_equal(should_be,CyberCoachUser.format)
  end

  test "base url" do
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'
    assert_equal(should_be,CyberCoachUser.base_uri)
  end

  test "resource path" do
    should_be = '/users'
    assert_equal(should_be,CyberCoachUser.resource_path)
  end

  test "create empty test user" do
    empty_user = CyberCoachUser.new
  end


  test "create test user" do
    user = CyberCoachUser.new username: 'lexruee', password: 'hidden'
    assert_equal('lexruee',user.username)
    assert_equal('hidden',user.password)
  end

  test "test getter methods" do
    empty_user = CyberCoachUser.new
    [:username,:password, :email, :publicvisible].each do |property|
      assert_not_nil empty_user.send property
    end
  end

  test "test setter methods" do
    empty_user = CyberCoachUser.new
    [:username=,:password=, :email=, :publicvisible=].each do |property|
      assert_not_nil empty_user.send property, 'some value'
    end
  end

end
