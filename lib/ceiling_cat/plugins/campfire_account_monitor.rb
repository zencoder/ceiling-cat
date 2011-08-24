module CeilingCat
  module Plugin
    class CampfireAccountMonitor < CeilingCat::Plugin::Base
      # See lib/ceiling_cat/plugins/base.rb for the methods available by default.
      # Plugins are run in the order they are listed in the Chatfile.
      # When a plugin returns anything other than nil the plugin execution chain is halted.
      # If you want your plugin to do something but let the remaining plugins execute, return nil at the end of your method.

      # handle manages a plugin's entire interaction with an event.
      # If you only want to execute commands - "![command]" - leave handle alone (or remove it and define commands below)
      def handle
        if room.connection.config.service.downcase == "campfire" && event.type == :entrance
          user_count = room.connection.total_user_count
          max_users = room.connection.config.max_users || 100
          if room.plugin_installed?("notifo") && user_count > max_users-2
            room.plugin("notifo").new(@event).deliver("#{user_count} of #{max_users} max connections to Campfire.") 
          end
        end
        super
      end

      # If you want the plugin to run when certain text is sent use commands instead of handle.
      # Ceiling Cat will watch for "![command]" or "[name]: [command" and execute the method for that command.
      def self.commands
        [{:command => "total users", :description => "Gets the total number of current users in chat", :method => "total_users", :public => false}]
      end

      def self.description
        "For monitoring Campfire connection limits"
      end

      def self.name
        "Campfire account monitor"
      end

      def self.public?
        false
      end

      def total_users
        if room.connection.config.service.downcase == "campfire"
          reply "#{room.connection.total_user_count} connections currently used"
        end
      end
    end
  end
end
    