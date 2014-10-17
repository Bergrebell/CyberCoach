require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  test "should get proposals" do
    get :proposals
    assert_response :success
  end

end
