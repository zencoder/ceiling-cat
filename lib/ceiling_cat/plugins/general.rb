module CeilingCat
  module Plugin
    class General < CeilingCat::Plugin::Base
      # See lib/ceiling_cat/plugins/base.rb for the methods available by default.
      # Plugins are run in the order they are listed in the Chatfile.
      # When a plugin returns anything other than nil the plugin execution chain is halted.
      # If you want your plugin to do something but let the remaining plugins execute, return nil at the end of your method.

      # handle manages a plugin's entire interaction with an event.
      # If you only want to execute commands - "![command]" - leave handle alone (or remove it and define commands below)
      def handle
        super
      end

      # If you want the plugin to run when certain text is sent use commands instead of handle.
      # Ceiling Cat will watch for "![command]" or "[name]: [command" and execute the method for that command.
      def self.commands
        [{:command => "debugger", :description => "Load the debugger", :method => "run_debug", :public => false},
         {:command => "enable debug", :description => "Enable debuggers", :method => "enable_debug", :public => false},
         {:command => "disable debug", :description => "Disable debuggers", :method => "disable_debug", :public => false}]
      end

      def self.description
        "General tasks for development"
      end

      def self.name
        "General"
      end

      def self.public?
        false
      end

      def run_debug
        if !store["debug_mode"].nil? && store["debug_mode"] == "true"
          reply "Opening debugger in terminal"
          debugger
        else
          reply "Debugging is disabled - !enable debug to activate it."
        end
      end
      
      def enable_debug
        store["debug_mode"] ||= "true"
        reply "debugging enabled"
      end
      
      def disable_debug
        store["debug_mode"] ||= "false"
        reply "debugging disabled"
      end
    end
  end
end
    