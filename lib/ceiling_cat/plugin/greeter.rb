module CeilingCat
  module Plugin
    class Greeter < CeilingCat::Plugin::Base

      def handle
        if event.type == :entrance
          if user.is_guest?
            message = []
            if room.registered_users_in_room?
              message << "Hey #{user.name}! Welcome to Zencoder Support Chat."
              if room.registered_users_in_room.size > 1
                message << "#{room.list_of_registered_users_in_room} are Zencoder employees who can help you out."
              else
                message << "#{room.list_of_registered_users_in_room} is a Zencoder employee who can help you out."
              end
            else
              message << "Hey #{user.name}! Nobody from Zencoder is in Support Chat right now."
            end
            room.say(message)
          end
        end
      end
    end
  end
end