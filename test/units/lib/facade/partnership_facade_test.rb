require 'test_helper'
require 'pp'
class TestSportSessionFacade < ActiveSupport::TestCase

  test "if creating a partnership works" do

    confirmer = Facade::User.authenticate username: 'gaudiuser', password: 'test'
    assert confirmer.authorized?
    proposer = Facade::User.authenticate username: 'asarteam3', password: 'scareface'
    assert proposer.authorized?
    partnership = Facade::Partnership.create confirmer: confirmer, proposer: proposer
    assert_not_nil partnership
    assert partnership.auth_proxy.authorized?
    assert partnership.save

    # and now the otherway arround

    partnership = Facade::Partnership.create confirmer: proposer, proposer: confirmer
    assert_not_nil partnership
    assert partnership.save

    gaudiuser = proposer.friends.detect {|friend| friend.username == confirmer.username }
    asarteam2 = confirmer.friends.detect {|friend| friend.username == proposer.username }

    assert_equal 'gaudiuser', gaudiuser.username
    assert_equal 'asarteam3', asarteam2.username

  end


  test "if deleting a partnership works" do
    user = Facade::User.authenticate username: 'gaudiuser', password: 'test'
    another_user = Facade::User.authenticate username: 'asarteam3', password: 'scareface'
    partnership = user.partnerships.detect { |p| p.associated_with?(another_user)}
    assert_not_nil partnership
    assert partnership.is_a?(Facade::Partnership)
    assert partnership.confirmed_by?(user) == true
    assert partnership.delete

    p = RestAdapter::Models::Partnership.retrieve 'gaudiuser;asarteam3'

    assert p.confirmed_by?(user) == false



  end

end