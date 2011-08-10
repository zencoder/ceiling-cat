module CeilingCat
  module Campfire
    class Event < CeilingCat::Event
      
      def type
        case @type
        when "EnterMessage"
          :entrance
        when "TextMessage"
          :chat
        when "LeaveMessage", "KickMessage"
          :exit
        end
      end
      
    end
  end
end