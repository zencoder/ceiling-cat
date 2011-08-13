require 'yaml'

module CeilingCat
  module Storage
    class Yaml < CeilingCat::Storage::Base
      class << self
        attr_reader :file

        # Sets the path to the file this store will persist to, and forces
        # a reload of all of the data.
        def file=(f)
          @file = f
          @internal = nil # force reload
          @file
        end

        # Sets the key +k+ to the value +v+ 
        def []=(k, v)
          internal[k] = v
          persist!
          v
        end

        # Returns the value at the key +k+.
        def [](k)
          internal[k]
        end

        private

        # The internal in-memory representation of the yaml file
        def internal
          @internal ||= begin
            YAML.load_file(file) rescue {}
          end
        end

        # Persists the data in this store to disk. Throws an exception if
        # we don't have a file set.
        def persist!
          raise "CeilingCat::Storage::Yaml.file must be set" unless file
          f = File.open(file, "w")
          f.puts internal.to_yaml
          f.close
        end
      end
    end
  end
end