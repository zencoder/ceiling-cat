module CeilingCat
  module Storage
    class Hash < CeilingCat::Storage::Base
      class << self

        # Stores +v+ in the hash.
        def []=(k, v)
          internal[k] = v
        end

        # Returns the value at key +k+.
        def [](k)
          internal[k]
        end

        private
        # The hash the data is being stored in.
        def internal
          @internal ||= {}
        end
  
      end
    end
  end
end