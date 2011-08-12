module CeilingCat
  module Plugin
    class Calc < CeilingCat::Plugin::Base

      def handle
        if command = commands.find{|command| body =~ command[:regex]}
          begin
            reply("#{body_without_command(command[:regex])} = #{eval body_without_command(command[:regex])}")
          rescue
            reply ["I couldn't calculate that. Are you sure it's a math equation?", "error: #{$!}"]
          end
        end
      end
      
      def self.commands
        [{:regex => /^calculate/i, :name => "calculate", :description => "Performs basic math functions - 'calculate 7*5'"}]
      end
      
      def self.description
        "A basic calculator, for all your mathin' needs!"
      end
      
      def self.name
        "Calculator"
      end

    end
  end
end