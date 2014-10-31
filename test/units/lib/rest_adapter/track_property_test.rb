require 'pp'
require 'base64'
require 'json'

class TestTrackProperty <  ActiveSupport::TestCase

  test "create a track property" do
    track = RestAdapter::Models::TrackProperty.new
  end


  test "add data to track property" do
    track = RestAdapter::Models::TrackProperty.new({ test: 'some text' })
    assert_not_nil track.data
  end


  test "to_s method" do
    track = RestAdapter::Models::TrackProperty.new({ test: 'some text' })
    json = ({ test: 'some text' }).to_json
    base_64 = Base64.encode64(json)
    assert_equal base_64, track.to_s
  end


  test "return a hash if creating from a string fails" do
    track = RestAdapter::Models::TrackProperty.create '<user></user>'
    assert_not_nil track.data
    assert track.data.is_a?(Hash)
  end


  test "return parsed json hash if creating from a string succeeds" do
    track = RestAdapter::Models::TrackProperty.create "{ user: 'alex', test: 'some value'}"
    assert_not_nil track.data
    assert track.data.is_a?(Hash)
    assert 'alex', track.data['user']
    assert 'some value', track.data['test']
  end


  test "return parsed json hash if creating from a encoded base64 string succeeds" do
    base_64 = Base64.encode64("{ user: 'alex', test: 'some value'}")
    track = RestAdapter::Models::TrackProperty.create base_64
    assert_not_nil track.data
    assert track.data.is_a?(Hash)
    assert 'alex', track.data['user']
    assert 'some value', track.data['test']
  end

end
