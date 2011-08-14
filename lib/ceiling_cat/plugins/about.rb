module CeilingCat
  module Plugin
    class About < CeilingCat::Plugin::Base
      def self.commands
        [{:regex => "plugins", :name => "plugins", :description => "List of installed plugins.", :method => "list_plugins"},
         {:regex => "commands", :name => "commands", :description => "List of available commands.", :method => "list_commands"},
         {:regex => "employees", :name => "employees", :description => "List of employees in the room.", :method => "list_employees"}]
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
        reply room.plugin_descriptions
      end

      def list_commands
        messages = room.available_commands
        messages << "Run commands with '![command]' or '#{room.me.name}: [command]'"
        reply messages
      end
      
      def list_employees
        members = room.list_of_users_in_room(:type => "member")
        reply "#{members} #{pluralize(members.size, "is a", "are")} Zencoder #{pluralize(members.size, "employee")}."
      end
    end
  end
end