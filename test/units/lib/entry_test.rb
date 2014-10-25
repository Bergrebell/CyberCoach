require 'pp'
class TestEntryAdapter  < ActiveSupport::TestCase

  test "retrieve an entry" do
    entry = RestAdapter::Entry.retrieve 'users/newuser4/Running/22/'
    pp entry
    assert_equal RestAdapter::Entry::Type::Running, entry.type


  end

end