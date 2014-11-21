require 'rails_helper'

RSpec.describe "friendships/index", :type => :view do
  before(:each) do
    assign(:friendships, [
      Friendship.create!(
        :user_id => 1,
        :friend_id => 2,
        :confirmed => false
      ),
      Friendship.create!(
        :user_id => 1,
        :friend_id => 2,
        :confirmed => false
      )
    ])
  end

  it "renders a list of friendships" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
