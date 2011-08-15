module CeilingCat
  module Plugin
    class Calc < CeilingCat::Plugin::Base      
      def self.commands
        [{:command => "calculate", :description => "Performs basic math functions - '!calculate 7*5'", :method => "calculate", :public => true}]
      end
      
      def self.description
        "A basic calculator, for all your mathin' needs!"
      end
      
      def self.name
        "Calculator"
      end
      
      def self.public?
        true
      end
      
      def calculate
        begin
          math = body.gsub(/[^\d+-\/*\(\)\.]/,"") # Removing anything but numbers, operators, and parens
          if math.length > 0 && math =~ /^\d.+\d$/
            reply "#{math} = #{eval math}"
          else
            reply "I don't think that's an equation. Want to try something else?"
          end
        rescue => e
          raise e
        end
      end
    end
  end
end