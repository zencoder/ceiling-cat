require 'ostruct'

module CeilingCat
  class Setup
    
    attr_accessor :config
    
    class << self
      # Class-level config. This is set by the +configure+ class method,
      # and is used if no configuration is passed to the +initialize+
      # method.
      attr_accessor :config
    end
    
    # Configures the connection at the class level. When the +ceiling_cat+ bin
    # file is loaded, it evals the file referenced by the first
    # command-line parameter. This file can configure the connection
    # instance later created by +robut+ by setting parameters in the
    # CeilingCat::Connection.configure block.
    def self.configure
      self.config = OpenStruct.new
      yield config
    end

    # Sets the instance config to +config+, converting it into an
    # OpenStruct if necessary.
    def config=(config)
      @config = config.kind_of?(Hash) ? OpenStruct.new(config) : config
    end
    
    def initialize(_config = nil)
      self.config = _config || self.class.config
    end
    
    def connect
      case self.config.service.downcase
      when 'campfire'
        require 'ruby-debug'
        debugger
        connection = CeilingCat::Campfire::Connection.new(self.config)
        room = CeilingCat::Campfire::Room.new(:connection => connection, :room_name => self.config.room)
        room.watch
      else
        raise CeilingCat::UnsupportedChatServiceError.new("#{self.config.service} is not a supported chat service.")
      end
    end
    
  end
end
