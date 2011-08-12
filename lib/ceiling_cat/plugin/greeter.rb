module CeilingCat
  module Plugin
    class Greeter < CeilingCat::Plugin::Base

      def handle
        if event.type == :entrance
          if user.is_guest?
            message = []
            members = room.users_in_room(:type => "member")
            if !members.empty?
              message << "Hey #{user.name}! Welcome to Zencoder Support Chat."
              if members.size > 1
                message << "#{room.list_of_users_in_room(:type => "member")} are Zencoder employees who can help you out."
              else
                message << "#{room.list_of_users_in_room(:type => "member")} is a Zencoder employee who can help you out."
              end
            else
              message << "Hey #{user.name}! Nobody from Zencoder is in Support Chat right now."
            end
            reply message
          end
        end
      end
      
      def self.name
        "Greeter"
      end
      
      def self.description
        "Welcomes visitors to chat and lets them know who can help."
      end
    end
  end
end