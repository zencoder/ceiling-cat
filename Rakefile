require 'bundler/gem_tasks'

namespace :gem do
  namespace :plugin do
    desc "Create a new plugin"
    task :create do
      raise "You need to set a name! `rake plugin:create name=[plugin_name]`" unless ENV["name"]
      name = ENV["name"].downcase
      file = File.join("lib", "ceiling_cat", "plugins", "#{name}.rb")

      unless File.exists? file
        contents = plugin_base(name)
        File.open(file, 'w') {|f| f.write(contents) }
        puts "Plugin '#{name}' created at #{file}."
        puts "Make sure you require it in your Chatfile and add it to your config.plugins so it runs."
      else
        puts "A plugin named '#{name}' already exists. Try another name."
      end
    end
  end

  def plugin_base(name)
  %Q{module CeilingCat
  module Plugin
    class #{name.camelize} < CeilingCat::Plugin::Base
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
        [{:command => "#{name}", :description => "Does something", :method => "#{name}", :public => false}]
      end

      def self.description
        "A plugin called #{name.capitalize}"
      end

      def self.name
        "#{name.gsub("_"," ").capitalize}"
      end

      def self.public?
        false
      end

      def #{name}
        reply "You've created the '#{name.capitalize}' plugin. Now make it do something awesome!"
      end
    end
  end
end
}
  end
end

class String
  def camelize
    self.split("_").each{|z|z.capitalize!}.join("")
  end
end