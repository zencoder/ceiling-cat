module CeilingCat
  module Campfire
    class Room < CeilingCat::Room
      attr_accessor :campfire_room

      def initialize(opts={})
        super
        @campfire_room = @connection.campfire.find_room_by_name(opts[:room_name])
      end

      def watch
        puts "Watching room..."
        setup_interrupts
        begin
          loop do
            begin
              Timeout::timeout(300) do
                @campfire_room.listen do |event|
                  begin
                    if event[:type] != "TimestampMessage"
                      user = CeilingCat::User.new(event[:user][:name], :id => event[:user][:id], :role => event[:user][:type])

                      unless is_me?(user) # Otherwise CC will talk to itself
                        event = CeilingCat::Campfire::Event.new(self,event[:body], user, :type => event[:type])
                        event.handle
                        users_in_room(:reload => true) if event.type != :chat # If someone comes or goes, reload the list.
                      end
                    end
                  rescue => e
                    raise e
                  end
                end
              end
            rescue Timeout::Error
              retry # Reconnect regularly to keep CC talking with Campfire
            end
          end
        rescue Faraday::Error::ParsingError
          puts "Error parsing response. Campfire may be down. Trying again."
          retry
        rescue HTTP::Parser::Error
          puts "Trouble parsing the HTTP response."
          retry
        rescue ReloadException => e
          retry
        rescue NoMethodError => e
          puts "No Method Error"
          e.backtrace.each do |line|
            puts "Backtrace: #{line}"
          end
          retry
        rescue StandardError => e
          puts e.class
          e.backtrace.each do |line|
            puts "Backtrace: #{line}"
          end
          retry
        end
      end

      def is_me?(user)
        user.id == me.id
      end

      def me
        @me ||= CeilingCat::User.new(@connection.campfire.me[:name], :id => @connection.campfire.me[:id], :role => @connection.campfire.me[:type])
      end

      def users_in_room(opts={})
        if opts[:reload] || @users_in_room.nil?
          puts "Requesting user list"
          @users_in_room = @campfire_room.users
        end

        @users_in_room.collect{ |user_in_room|
          user = CeilingCat::User.new(user_in_room[:name], :id => user_in_room[:id], :role => user_in_room[:type])
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

      def say(something_to_say)
        Array(something_to_say).each do |line|
          @campfire_room.speak(line)
        end
      end

      def setup_interrupts
        trap('INT') do
          puts "Leaving room...."
          @campfire_room.leave if @campfire_room
          exit 1
        end

        trap('USR1') do
          puts "Leaving room"
          @campfire_room.leave if @campfire_room
          # logger.info "Reloading config"
          # config(true)
          # raise ReloadException.new("Rejoin room please, ceiling cat")
        end
      end
    end
  end
end
