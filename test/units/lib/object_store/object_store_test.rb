
class TestObjectStore < ActiveSupport::TestCase

  test "add something to the object store" do
    ObjectStore::Store.set(:hello,'somevalue')
    value = ObjectStore::Store.get(:hello)
    assert_equal 'somevalue', value
  end


  test "add and remove something to the object store" do
    ObjectStore::Store.set(:hello2,'somevalue')
    value = ObjectStore::Store.get(:hello2)
    assert_equal 'somevalue', value
    ObjectStore::Store.remove(:hello2)
    value = ObjectStore::Store.get(:hello2)
    assert_equal nil, value
  end


end