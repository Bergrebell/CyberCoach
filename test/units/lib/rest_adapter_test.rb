require 'test_helper'

class TestRestAdapter  < ActiveSupport::TestCase

  test "base resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::BaseResource.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::BaseResource.site
    assert_equal :json, RestAdapter::BaseResource.deserialize_format
    assert_equal :xml, RestAdapter::BaseResource.serialize_format

    assert_equal :json, RestAdapter::User.deserialize_format
    assert_equal :xml, RestAdapter::User.serialize_format
  end

end