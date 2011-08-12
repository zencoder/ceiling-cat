module CeilingCat
  module Plugin
    class Base
      attr_accessor :event
      
      def initialize(the_event)
        @event = the_event
      end
      
      def handle
        raise NotImplementedError, "Implement in plugin!"
      end
      
      def self.name
        self.class.to_s.gsub("CeilingCat::Plugin::","")
      end
      
      def self.description
        "No description"
      end
      
      def self.commands
        []
      end
      
      def commands
        self.class.commands || []
      end
      
      def event
        @event
      end
      
      def room
        event.room
      end
      
      def body
        event.body
      end
      
      def user
        event.user
      end
      
      def reply(message)
        room.say(message)
      end
      
      def body_without_command(command=nil)
        body.sub(command,"")
      end
      
      def talking_to_me?
        body =~ /(^|\s)#{room.me.name}(\s|$)/i
      end
      
      def words
        body.split
      end
      
      def body_without_nick
        body.sub(room.me.name,'')
      end
    end
  end
end