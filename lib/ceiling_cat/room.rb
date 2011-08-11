module CeilingCat
  class Room
    attr_accessor :connection, :room, :registered_users_in_room, :unregistered_users_in_room
    
    def initialize(opts={})
      @connection = opts[:connection]
    end
    
    def watch
      raise NotImplementedError, "Implement in chat files!"
    end
    
    def plugins
      @connection.plugins
    end
    
    def registered_users_in_room?
      registered_users_in_room.size > 0
    end
    
    def registered_users_in_room(reload=false)
      puts "parent class"
      @registered_users_in_room || []
    end
    
    def list_of_registered_users_in_room
      users = registered_users_in_room
      last_user = users.pop
      if users.size > 0
        return users.collect{|user| user["name"] }.join(", ") + " and #{ last_user["name"]}"
      else
        return last_user["name"]
      end
    end
    
    def unregistered_users_in_room?
      unregistered_users_in_room.size > 0
    end
    
    def unregistered_users_in_room(reload=false)
      @unregistered_users_in_room || []
    end
  end
end