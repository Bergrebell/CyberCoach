module ObjectStore

  class HashStore

    def initialize
      @store = Hash.new
    end

    def set(key,object)
      @store[key] = object
    end

    def get(key)
      @store[key]
    end

    def remove(key)
      object = @store[key]
      object.clean_up if defined? object.clean_up
      @store.delete(key)
    end
  end

  Store = HashStore.new

end