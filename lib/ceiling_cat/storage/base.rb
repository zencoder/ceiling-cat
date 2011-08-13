module CeilingCat
  module Storage
    class Base
      class << self

        # Sets the key +k+ to the value +v+ in the current storage system
        def []=(k,v)
          raise NotImplementedError, "Implement in storage type file!"
        end

        # Returns the value at the key +k+.
        def [](k)
          raise NotImplementedError, "Implement in storage type file!"
        end
      end
    end
  end
end
