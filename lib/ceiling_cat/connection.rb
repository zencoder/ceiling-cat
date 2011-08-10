module CeilingCat
  class Connection
    attr_accessor :config
    
    def initialize(config)
      @config=config
    end
    
    def plugins
      self.config.plugins
    end
    
  end
end
