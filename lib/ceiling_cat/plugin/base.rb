module CeilingCat
  module Plugin
    class Base
      attr_accessor :room, :body, :user, :type, :time
      
      def initialize(event)
        @room = event.room
        @body = event.body
        @user = event.user
        @type = event.type
        @time = event.time
      end
      
      def handle
        raise NotImplementedError, "Implement in plugin!"
      end
      
      def reply(message)
        @room.say(message)
      end
      
      def body_without_command
        @body.sub(command,"")
      end
      
      def talking_to_me?
        @body =~ /(^|\s)#{@room.me.name}(\s|$)/i
      end
      
      def words
        @body.split
      end
      
      def body_without_nick
        @body.sub(@room.me.name,'')
      end
    end
  end
end