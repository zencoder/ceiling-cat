module CeilingCat
  module Campfire
    class Event < CeilingCat::Event
      
      def handle
        puts "#{user.short_name} says: #{@body} at #{@time}"
      end
      
    end
  end
end