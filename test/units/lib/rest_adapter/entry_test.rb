require 'pp'
class TestEntryAdapter  < ActiveSupport::TestCase

  DateTimeFormatter = RestAdapter::Helper::DateTimeInjector


  test "retrieve a running entry over a uri" do
    entry = RestAdapter::Models::Entry.retrieve '/users/newuser4/Running/22/'
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.cc_id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_modified
    assert_equal DateTimeFormatter.call(1349166120000), entry.entry_date
    assert_not_nil entry.subscription
  end


  test "retrieve a running entry over a subscription object" do
    subscription = RestAdapter::Models::Subscription.retrieve user: 'newuser4', sport: 'running'
    entry = RestAdapter::Models::Entry.retrieve subscription: subscription, id: 22
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.cc_id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_modified
    assert_equal DateTimeFormatter.call(1349166120000), entry.entry_date
    assert_not_nil entry.subscription
  end


  test "retrieve a running entry over a subscription string" do
    entry = RestAdapter::Models::Entry.retrieve subscription: '/users/newuser4/running', id: 22
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.cc_id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_modified
    assert_equal DateTimeFormatter.call(1349166120000), entry.entry_date
    assert_not_nil entry.subscription
  end



  test "retrieve a soccer entry over a uri" do
    entry = RestAdapter::Models::Entry.retrieve '/partnerships/newuser4;newuser5/Soccer/24/'
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Soccer, entry.type
    assert_equal 24, entry.cc_id
    assert_equal '/CyberCoachServer/resources/partnerships/newuser4;newuser5/Soccer/24/', entry.uri
    assert_equal 'Düdingen', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal DateTimeFormatter.call(1412672187000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672187000), entry.date_modified
    assert_equal DateTimeFormatter.call(1347351720000), entry.entry_date
    assert_not_nil entry.subscription
  end


  test "retrieve a soccer entry over a partnership or users" do
    # first possibility
    entry = RestAdapter::Models::Entry.retrieve partnership: 'newuser4;newuser5', sport: 'soccer', id: 24
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Soccer, entry.type
    assert_equal 24, entry.cc_id
    assert_equal '/CyberCoachServer/resources/partnerships/newuser4;newuser5/Soccer/24/', entry.uri
    assert_equal 'Düdingen', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal DateTimeFormatter.call(1412672187000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672187000), entry.date_modified
    assert_equal DateTimeFormatter.call(1347351720000), entry.entry_date
    assert_not_nil entry.subscription

    # second possibility
    first_user = RestAdapter::Models::User.new username: 'newuser4'
    second_user = RestAdapter::Models::User.new username: 'newuser5'
    partnership = RestAdapter::Models::Partnership.new first_user: first_user, second_user: second_user
    entry = RestAdapter::Models::Entry.retrieve partnership: partnership, sport: 'soccer', id: 24
    assert_not_nil entry
  end


  test "retrieve a soccer entry over a user" do
    # first possibility
    entry = RestAdapter::Models::Entry.retrieve user: 'newuser4', sport: 'running', id: 22
    assert entry!= false
    assert_equal RestAdapter::Models::Entry::Type::Running, entry.type
    assert_equal 600, entry.course_length
    assert_equal 22, entry.cc_id
    assert_equal '/CyberCoachServer/resources/users/newuser4/Running/22/', entry.uri
    assert_equal 'Lausanne', entry.entry_location
    assert_equal 'Random text', entry.comment
    assert_equal RestAdapter::Privacy::Public, entry.public_visible
    assert_equal 11900, entry.entry_duration
    assert_equal 7, entry.number_of_rounds
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_created
    assert_equal DateTimeFormatter.call(1412672016000), entry.date_modified
    assert_equal DateTimeFormatter.call(1349166120000), entry.entry_date
    assert_not_nil entry.subscription

    # second possibility
    user = RestAdapter::Models::User.new username: 'newuser4'
    entry = RestAdapter::Models::Entry.retrieve user: user, sport: 'running', id: 22
    assert_not_nil entry
  end

  test "serialize an entry" do
    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam1', password: 'scareface'
    user = RestAdapter::Models::User.retrieve 'asarteam1'
    subscription = user.subscriptions.detect {|s| s.sport.name == 'Running'}
    hash = {
        :type =>  RestAdapter::Models::Entry::Type::Running,
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :public_visible => RestAdapter::Privacy::Public,
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :subscription => subscription
    }
    entry = RestAdapter::Models::Entry.new(hash)
    entry.track = {:test => 'test'}
    should_be = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/users/asarteam1/Running/'
    assert_equal should_be, entry.absolute_uri
    assert_equal '/CyberCoachServer/resources/users/asarteam1/Running/', entry.uri
  end


  test "create an entry" do
    assert false
    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam1', password: 'scareface'
    subscription = RestAdapter::Models::Subscription.retrieve('/users/asarteam1/Running')
    hash = {
        :type =>  RestAdapter::Models::Entry::Type::Running,
        :course_length => 700,
        :number_of_rounds => 7,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :public_visible => RestAdapter::Privacy::Public,
        :entry_duration => 10000,
        :entry_date => DateTime.now,
        :subscription => subscription
    }
    entry = RestAdapter::Models::Entry.new(hash)
    entry.track = {:test => 'test'}
    assert entry.cc_id==nil
    entry_uri = auth_proxy.save(entry)
    assert_not_nil entry_uri
  end


  test "update an entry" do
    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam1', password: 'scareface'
    entry = RestAdapter::Models::Entry.retrieve '/users/asarteam1/Running/73/'
    entry.comment = 'updated comment muhaaa'
    entry.track = {:test => 'test2'}
    assert_equal 73, entry.cc_id
    assert_equal '/CyberCoachServer/resources/users/asarteam1/Running/73/', entry.uri
    entry_uri = auth_proxy.save(entry)
  end


  test "create and delete an entry" do
    auth_proxy = RestAdapter::AuthProxy.new username: 'asarteam1', password: 'scareface'
    subscription = RestAdapter::Models::Subscription.retrieve('/users/asarteam1/Running')
    hash = {
        :type =>  RestAdapter::Models::Entry::Type::Running,
        :entry_location => 'Bern',
        :comment => 'Some comment',
        :public_visible => RestAdapter::Privacy::Public,
        :subscription => subscription
    }
    entry = RestAdapter::Models::Entry.new(hash)
    entry.track = {:test => 'test'}
    assert entry.cc_id==nil
    entry_uri = auth_proxy.save(entry)
    pp 'delete entry with uri: ' + entry_uri
    sleep 20
    entry = RestAdapter::Models::Entry.new uri: entry_uri
    pp auth_proxy.delete(entry)
  end


  test "initialize an entry using a setter to set property uri" do
    uri = '/CyberCoachServer/resources/users/asarteam1/Running/93/'
    entry = RestAdapter::Models::Entry.new
    entry.uri = uri
    entry.fetch!
  end


  test "initialize an entry using a uri in constructor" do
    uri = '/CyberCoachServer/resources/users/asarteam1/Running/93/'
    entry = RestAdapter::Models::Entry.new uri: uri
    entry.fetch!
  end




end