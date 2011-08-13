module CeilingCat
  module Plugin
    class About < CeilingCat::Plugin::Base
      def self.commands
        [{:regex => /^!plugins/i, :name => "!plugins", :description => "List of installed plugins.", :method => "list_plugins"},
         {:regex => /^!commands/i, :name => "!commands", :description => "List of available commands.", :method => "list_commands"},
         {:regex => /^!savenote/i, :name => "!savenote", :description => "Save a note.", :method => "savenote"},
         {:regex => /^!loadnote/i, :name => "!loadnote", :description => "Save a note.", :method => "loadnote"},
         {:regex => /^!employees/i, :name => "!employees", :description => "List of employees in the room.", :method => "list_employees"}]
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
        reply room.available_commands
      end
      
      def list_employees
        members = room.list_of_users_in_room(:type => "member")
        reply "#{members} #{pluralize(members.size, "is a", "are")} Zencoder #{pluralize(members.size, "employee")}."
      end
      
      def savenote
        store["note"] = body_without_command(/^!savenote /)
        reply "Note saved!"
      end
      
      def loadnote
        reply store["note"] || "There was no note..."
      end
    end
  end
end