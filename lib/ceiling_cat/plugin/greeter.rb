module CeilingCat
  module Plugin
    class Greeter < CeilingCat::Plugin::Base
      def handle
        message = []

        if event.type == :entrance
          members = room.users_in_room(:type => "member")
          guests = room.users_in_room(:type => "guest")
          if user.is_guest?
            if !members.empty?
              message << "Hey #{user.name}! Welcome to Zencoder Support Chat."
              if members.size > 1
                message << "#{room.list_of_users_in_room(:type => "member")} are Zencoder employees who can help you out."
              else
                message << "#{room.list_of_users_in_room(:type => "member")} is a Zencoder employee who can help you out."
              end
            else
              message << "Hey #{user.name}! Nobody from Zencoder is in Support Chat right now."
              room.plugin("notifo").new(@event).deliver("#{user.name} has logged in to chat.") if room.plugin_installed?("notifo")
            end
          elsif user.is_registered?
            if !guests.empty? && members.empty?
              message << "Oh good, a Zencoder employee. #{user.name} can answer any questions you have."
            end
          end
        end
        
        reply message unless message.empty?
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