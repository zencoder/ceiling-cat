module CeilingCat
  module Plugin
    class Metrics < CeilingCat::Plugin::Base
      # See lib/ceiling_cat/plugins/base.rb for the methods available by default.
      # Plugins are run in the order they are listed in the Chatfile.
      # When a plugin returns anything other than nil the plugin execution chain is halted.
      # If you want your plugin to do something but let the remaining plugins execute, return nil at the end of your method.

      # handle manages a plugin's entire interaction with an event.
      # If you only want to execute commands - "![command]" - leave handle alone (or remove it and define commands below)
      def handle
        if event.type == :entrance && user.is_guest?
          members_in_room = room.users_in_room(:type => "member").size > 0
          store["visitor_log"] ||= []
          store["visitor_log"] = store["visitor_log"] + [{:name => user.name, :at => Time.now, :employees_around => members_in_room.to_s}]
        end
        super
      end

      def self.description
        "A plugin called Metrics"
      end

      def self.name
        "Metrics"
      end

      def self.public?
        false
      end

      def metrics
        reply "You've created the 'Metrics' plugin. Now make it do something awesome!"
      end
    end
  end
end
    