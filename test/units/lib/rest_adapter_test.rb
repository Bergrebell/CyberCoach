require 'test_helper'

class TestRestAdapter  < ActiveSupport::TestCase

  test "base resource config" do
    assert_equal 'http://diufvm31.unifr.ch:8090', RestAdapter::BaseResource.base
    assert_equal '/CyberCoachServer/resources', RestAdapter::BaseResource.site
  end

end