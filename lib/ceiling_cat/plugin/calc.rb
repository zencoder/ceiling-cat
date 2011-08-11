module CeilingCat
  module Plugin
    class Calc < CeilingCat::Plugin::Base

      def handle
        if body =~ command
          begin
            reply("#{body_without_command} = #{eval body_without_command}")
          rescue
            reply "I couldn't calculate that. Are you sure it's a math equation?"
          end
        end
      end
      
      def command
        /^calculate/i
      end

    end
  end
end