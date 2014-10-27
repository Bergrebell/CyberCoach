require 'pp'
class TestEntryAdapter  < ActiveSupport::TestCase

  test "retrieve a running entry over a uri" do
    entry = RestAdapter::Models::Entry.retrieve 'users/newuser4/Running/22/'
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal 1412672016000, entry.date_created
    assert_equal 1412672016000, entry.date_modified
    assert_equal 1349166120000, entry.entry_date
    assert_not_nil entry.subscription
  end


  test "retrieve a soccer entry over a uri" do
    entry = RestAdapter::Models::Entry.retrieve 'partnerships/newuser4;newuser5/Soccer/24/'
    assert_equal RestAdapter::Models::Entry::Type::Soccer, entry.type
    assert_equal 24, entry.id
    assert_equal '/CyberCoachServer/resources/partnerships/newuser4;newuser5/Soccer/24/', entry.uri
    assert_equal 'Düdingen', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 1412672187000, entry.date_created
    assert_equal 1412672187000, entry.date_modified
    assert_equal 1347351720000, entry.entry_date
    assert_not_nil entry.subscription
  end


  test "retrieve a soccer entry over a partnership or users" do
    # first possibility
    entry = RestAdapter::Models::Entry.retrieve partnership: 'newuser4;newuser5', sport: 'soccer', id: 24
    assert_not_nil entry
    assert_equal RestAdapter::Models::Entry::Type::Soccer, entry.type
    assert_equal 24, entry.id
    assert_equal '/CyberCoachServer/resources/partnerships/newuser4;newuser5/Soccer/24/', entry.uri
    assert_equal 'Düdingen', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 1412672187000, entry.date_created
    assert_equal 1412672187000, entry.date_modified
    assert_equal 1347351720000, entry.entry_date
    assert_not_nil entry.subscription

    # second possibility
    first_user = RestAdapter::Models::User.new username: 'newuser4'
    second_user = RestAdapter::Models::User.new username: 'newuser5'
    partnership = RestAdapter::Models::Partnership.new first_user: first_user, second_user: second_user
    entry = RestAdapter::Models::Entry.retrieve partnership: partnership, sport: 'soccer', id: 24
    assert_not_nil entry

    # third possibility
    entry = RestAdapter::Models::Entry.retrieve first_user: 'newuser4', second_user: 'newuser5', sport: 'soccer', id: 24
    assert_not_nil entry

    # fourth possibility
    first_user = RestAdapter::Models::User.new username: 'newuser4'
    second_user = RestAdapter::Models::User.new username: 'newuser5'
    entry = RestAdapter::Models::Entry.retrieve first_user: first_user, second_user: second_user, sport: 'soccer', id: 24
    assert_not_nil entry

  end


  test "retrieve a soccer entry over a user" do
    # first possibility
    entry = RestAdapter::Models::Entry.retrieve user: 'newuser4', sport: 'running', id: 22
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal 1412672016000, entry.date_created
    assert_equal 1412672016000, entry.date_modified
    assert_equal 1349166120000, entry.entry_date
    assert_not_nil entry.subscription

    # second possibility
    user = RestAdapter::Models::User.new username: 'newuser4'
    entry = RestAdapter::Models::Entry.retrieve user: user, sport: 'running', id: 22
    assert_not_nil entry
  end

  test "create an entry" do

    auth_proxy = RestAdapter::AuthProxy.new username: 'alex', password: 'scareface'
    user = RestAdapter::Models::User.retrieve 'alex'



  end


end