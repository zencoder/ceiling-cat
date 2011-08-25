module CeilingCat
  class Room
    attr_accessor :connection, :room, :users_in_room, :me

    def initialize(opts={})
      @connection = opts[:connection]
    end

    def watch
      raise NotImplementedError, "Implement in chat service files!"
    end

    def say
      raise NotImplementedError, "Implement in chat service files!"
    end

    def me
      raise NotImplementedError, "Implement in chat service files or define config.nickname!" unless config.nickname
      @me ||= CeilingCat::User.new(config.nickname)
    end

    def users_in_room(type=nil)
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

    def store
      @connection.storage
    end

    def plugin_descriptions(show_private=false)
      messages = []
      plugins.each do |plugin|
        messages << "#{plugin.name}: #{plugin.description}" if show_private || plugin.public?
      end
      messages
    end

    def available_commands(show_private=false)
      messages = []
      plugins.each do |plugin|
        if !plugin.commands.empty? && (plugin.public? || show_private)
          messages << "Commands for #{plugin.name}"
          plugin.commands.each do |command|
            messages << "-- #{command[:command]}: #{command[:description]}" if show_private || command[:public]
          end
        end
      end
      messages
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