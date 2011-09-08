module CeilingCat
  class Connection
    attr_accessor :config

    def initialize(config)
      @config=config
      @config.storage ||= CeilingCat::Storage::Hash
    end

    def plugins
      self.config.plugins
    end

    def storage
      self.config.storage
    end

  end
end
