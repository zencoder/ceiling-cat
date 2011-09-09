module CeilingCat
  module Plugin
    class Messages < CeilingCat::Plugin::Base
      # See lib/ceiling_cat/plugins/base.rb for the methods available by default.
      # Plugins are run in the order they are listed in the Chatfile.
      # When a plugin returns anything other than nil the plugin execution chain is halted.
      # If you want your plugin to do something but let the remaining plugins execute, return nil at the end of your method.

      # handle manages a plugin's entire interaction with an event.
      # If you only want to execute commands - "![command]" - leave handle alone (or remove it and define commands below)
      def handle
        if event.type == :entrance
          messages = []
          if messages_for_user = self.class.messages_for(user.name)
            messages << "Hey #{user.name}! I have a message to deliver to you:"
            messages += messages_for_user.collect{|message| "From #{message[:from]}: #{message[:body]}"}
            reply messages
          end
          false
        else
          super
        end
      end

      # If you want the plugin to run when certain text is sent use commands instead of handle.
      # Ceiling Cat will watch for "![command]" or "[name]: [command" and execute the method for that command.
      def self.commands
        [{:command => "message for", :description => "Leave a message for someone. i.e. '!message for John Doe: You forgot to lock the door after work last night.'", :method => "save_message", :public => true}]
      end

      def self.description
        "A plugin called Messages"
      end

      def self.name
        "Messages"
      end

      def self.public?
        false
      end

      def save_message
        recipient,*body = body_without_nick_or_command("message for").split(":")
        if room.users_in_room.any?{|user| user.name == recipient.strip}
          reply "Why leave that messsage? #{recipient.strip} is here!"
        else
          self.class.add(:to => recipient.strip, :from => user.name, :body => body.join(":").strip)
          reply "Message saved! I'll deliver it the next time #{recipient.strip} is around."
        end
      end
      
      def self.add(opts={})
        return false unless opts[:to] && opts[:from] && opts[:body]
        store["messages"] ||= []
        store["messages"] = (store["messages"] + [{:to => opts[:to], :from => opts[:from], :body => opts[:body]}]).uniq
      end
      
      def self.list
        store["messages"] ||= []
      end
      
      def self.messages_for(name)
        store["messages"] ||= []
        store["messages"].find_all{ |message| message[:to] == name }
      end
    end
  end
end
