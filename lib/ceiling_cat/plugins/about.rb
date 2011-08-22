module CeilingCat
  module Plugin
    class About < CeilingCat::Plugin::Base
      def self.commands
        [{:command => "plugins", :description => "List of installed plugins.", :method => "list_plugins"},
         {:command => "commands", :description => "List of available commands.", :method => "list_commands", :public => true},
         {:command => "users", :description => "List of registered in the room.", :method => "list_users", :public => true},
         {:command => "guests", :description => "List of guests in the room.", :method => "list_guests", :public => true}]
      end

      def self.description
        "About the currently running Ceiling Cat"
      end

      def self.name
        "About"
      end

      def self.public?
        true
      end

      def list_plugins
        reply room.plugin_descriptions(user.is_registered?)
      end

      def list_commands
        messages = room.available_commands(user.is_registered?) # Show all commands if the user is registered, otherwise only show private commands
        messages << "Run commands with '![command]' or '#{room.me.name}: [command]'"
        reply messages
      end
      
      def list_users
        members = room.list_of_users_in_room(:type => "member")
        reply "#{members} #{pluralize(members.size, "is a", "are")} #{pluralize(members.size, "registered user")}."
      end
      
      def list_guests
        guests = room.list_of_users_in_room(:type => "guest")
        reply "#{guests} #{pluralize(members.size, "is a", "are")} #{pluralize(members.size, "guest")}."
      end
    end
  end
end