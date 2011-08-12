module CeilingCat
  module Plugin
    class About < CeilingCat::Plugin::Base

      def handle
        if command = commands.find{|command| body =~ command[:regex]}
          begin
            if body =~ /^!plugins/
              reply room.installed_plugins
            elsif body =~ /^!commands/
              reply room.available_commands
            end
          rescue => e
            raise e
          end
        end
      end
      
      def self.commands
        [{:regex => /^!plugins/i, :name => "!plugins", :description => "List all installed plugins."},
         {:regex => /^!commands/i, :name => "!commands", :description => "List all available commands."}]
      end
      
      def self.description
        "About the currently running Ceiling Cat"
      end
      
      def self.name
        "About"
      end

    end
  end
end