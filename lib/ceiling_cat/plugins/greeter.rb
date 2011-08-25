module CeilingCat
  module Plugin
    class Greeter < CeilingCat::Plugin::Base
      def handle
        messages = []

        if event.type == :entrance
          members = room.users_in_room(:type => "member")
          guests = room.users_in_room(:type => "guest")
          if user.is_guest?
            messages << "Hey #{user.name}!"
          elsif user.is_registered?
            messages << "Nice to see you again #{user.name}"
          end
          reply messages unless messages.empty?
        elsif event.type == :chat
          super
        end
      end
      
      def self.name
        "Greeter"
      end
      
      def self.description
        "Welcomes visitors and memebrs to chat."
      end
    end
  end
end