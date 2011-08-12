module CeilingCat
  module Plugin
    class About < CeilingCat::Plugin::Base
      def self.commands
        [{:regex => /^!plugins/i, :name => "!plugins", :description => "List all installed plugins.", :method => "list_plugins"},
         {:regex => /^!commands/i, :name => "!commands", :description => "List all available commands.", :method => "list_commands"}]
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
    end
  end
end