module CeilingCat
  module IRC
    class Event < CeilingCat::Event
      
      def type
        case @type
        when "EnterMessage", :entrance
          :entrance
        when "TextMessage", :chat
          :chat
        when "LeaveMessage", "KickMessage", :exit
          :exit
        end
      end
      
    end
  end
end