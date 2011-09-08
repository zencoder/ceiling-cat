module CeilingCat
  module IRC
    class Room < CeilingCat::Room
      attr_accessor :user_names, :ops_names

      def initialize(opts={})
        super
        @ops_names = []
      end

      def irc
        @connection.irc
      end

      def watch
        puts "Watching room..."
        irc.connect
        if irc.connected?
          irc.nick config.nickname
          irc.pass config.password if config.password.present?
          irc.user config.nickname, "+B", "*", config.nickname

          while line = irc.read
            # Join a channel after MOTD
            if line.split[1] == '376'
              irc.join config.room
            elsif line.split[1] == "353"
              @user_names = line.match(/:.+\s353\s.+[\s@]?\s#.+\s:(.+)/i)[1].split
              irc.privmsg "chanserv", "access #{config.room} list"
            elsif match = line.match(/:.+\sNOTICE.+:\d\s+(\w+)\s+\+(\w+)/)
              @ops_names << match[1] if match[2].include?("O")
              @ops_names.uniq!
            end

            puts "Received: #{line}"
            begin
              if message = message_parts(line)
                user = CeilingCat::User.new(message[:name], :role => user_role(message[:name]))
                if !is_me?(user)
                  event = CeilingCat::Campfire::Event.new(self, message[:body], user, :type => message[:type])
                  event.handle
                end
              end
            rescue => e
              raise e
            end
          end
        end
      rescue Interrupt
        puts "Leaving room..."
        irc.part("#{config.room}")
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
        retry
      end

      def say(something_to_say)
        Array(something_to_say).each do |line|
          irc.privmsg config.room, line
        end
      end

      def users_in_room(opts={})
        @user_names.collect {|user_name|
          user_name = user_name.sub(/^@/,"")
          user = CeilingCat::User.new(user_name, :role => user_role(user_name))
          unless is_me?(user)
            if opts[:type].present?
              if user.role.to_s.downcase == opts[:type].downcase
                user
              end
            else
              user
            end
          end
        }.compact
      end

      def user_role(name)
        if @ops_names.include?(name)
          "member"
        else
          "guest"
        end
      end

      def is_me?(user)
        user.name == me.name
      end

      def me
        @me ||= CeilingCat::User.new(config.nickname, :role => "member")
      end

      def message_parts(message)
        if message =~ /\sPRIVMSG\s/
          parts = message.match /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(#.+):(.+)/i
          return {:name => parts[1], :body => parts[5], :type => :chat}
        elsif message =~ /\sJOIN\s/
          parts = message.match /^:(.+?)!(.+?)@(.+?)\s(.+)\s:(#.+)/i
          return {:name => parts[1], :body => nil, :type => :entrance}
        elsif message =~ /PING\s/
          puts "Sent: PONG"
          irc.pong message.match(/PING\s:(.+)/)[1]
          return nil
        else
          return nil
        end
      end
    end
  end
end