module CeilingCat
  class Room
    attr_accessor :connection, :room, :body, :user, :type, :registered_users_in_room, :unregistered_users_in_room
    
    def initialize(opts={})
      @connection = opts[:connection]
    end
    
    def watch
      CeilingCat::Event.new(self, @body, @user, @type).handle if (@body || @user || @type)
    end
    
    def plugins
      @connection.plugins
    end
    
    def registered_users_in_room
      if @registered_users_in_room
        @registered_users_in_room
      else
        []
      end
    end
    
    def unregistered_users_in_room
      if @unregistered_users_in_room
        @unregistered_users_in_room
      else
        []
      end
    end
  end
end