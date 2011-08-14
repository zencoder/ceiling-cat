module CeilingCat
  module Plugin
    class Base
      attr_accessor :event

      def initialize(event)
        @event = event
      end

      def handle
        if command = commands.find{|command| body =~ /^(!|#{room.me.name}:?\s*)#{command[:command]}/i}
          begin
            self.send command[:method]
          rescue => e
            reply "There was an error: #{$!}"
            raise e
          end
        end
      end

      def self.name
        self.class.to_s.gsub("CeilingCat::Plugin::","")
      end

      def self.description
        "No description"
      end

      def self.public?
        false #assume we don't want people to know a plugin is available.
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
      
      def store
        self.class.store
      end
      
      def self.store
        CeilingCat::Setup.config.storage
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
      
      def words
        body.split
      end

      def body_without_command(command,text=body)
        text.sub(/^!#{command}:?\s*/i,"").strip
      end

      def body_without_nick(text=body)
        text.sub(/^#{room.me.name}:?\s*/i,'').strip
      end
      
      def body_without_nick_or_command(command,text=body)
        body_without_command(command, body_without_nick(text).sub(/^#{command}/i,"!#{command}"))
      end
      
      def pluralize(n, singular, plural=nil)
        if n == 1
            "#{singular}"
        elsif plural
            "#{plural}"
        else
            "#{singular}s"
        end
      end
    end
  end
end