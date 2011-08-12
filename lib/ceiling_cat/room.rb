module CeilingCat
  class Room
    attr_accessor :connection, :room, :users_in_room
    
    def initialize(opts={})
      @connection = opts[:connection]
    end
    
    def watch
      raise NotImplementedError, "Implement in chat service files!"
    end
    
    def say
      raise NotImplementedError, "Implement in chat service files!"
    end
    
    def plugins
      @connection.plugins
    end
    
    def config
      @connection.config
    end
    
    def plugin_installed?(name)
      !plugin(name).nil?
    end
    
    def plugin(name)
      plugins.find{|plugin| plugin.name.downcase == name.to_s.downcase || plugin.class == name}
    end
    
    def plugin_descriptions(all=false)
      messages = []
      plugins.each do |plugin|
        messages << "#{plugin.name}: #{plugin.description}" if all || plugin.public?
      end
      messages
    end
    
    def available_commands
      messages = []
      plugins.each do |plugin|
        if !plugin.commands.empty? && plugin.public?
          messages << "Commands for #{plugin.name}"
          plugin.commands.each do |command|
            messages << "-- #{command[:name]}: #{command[:description]}"
          end
        end
      end
      messages
    end
    
    def users_in_room(type=nil)
      raise NotImplementedError, "Implement in chat service files!"
    end
    
    def list_of_users_in_room(type=nil)
      users = users_in_room(type)
      last_user = users.pop
      if users.size > 0
        return users.collect{|user| user["name"] }.join(", ") + " and #{ last_user["name"]}"
      else
        return last_user["name"]
      end
    end
  end
end