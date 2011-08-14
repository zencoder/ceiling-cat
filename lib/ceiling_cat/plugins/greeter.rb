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
              message << "Today is a holiday, so there aren't any Zencoder employees around." if room.plugin_installed?("days") && room.plugin("days").is_a_holiday?
              message << "There are usually Zencoder employees in chat during weekday business hours - 8am to 5pm Pacific."
              message << "Feel free to ask any questions you have along with an email address where we can reach you, and a Zencoder employee will get back to you soon, usually towards the beginning of the next business day."
              if guests.size > 1
                message << "But be aware that other people currently in the room will be able to see anything you write, so don't leave any information you don't want public."
              end
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