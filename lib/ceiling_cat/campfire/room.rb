module CeilingCat
  module Campfire
    class Room < CeilingCat::Room
      attr_accessor :me
      
      def initialize(opts={})
        super
        @campfire_room = @connection.campfire.find_room_by_name(opts[:room_name])
      end
      
      def watch
        puts "Watching room..."
        setup_interrupts
        begin
          @campfire_room.listen do |event|
            begin
              user = CeilingCat::User.new(event[:user][:name], :id => event[:user][:id], :role => event[:user][:type])
              unless is_me?(user) # Otherwise CC will talk to itself
                event = CeilingCat::Campfire::Event.new(self,event[:body], user, :type => event[:type])
                event.handle
                users_in_room(:reload => true) if event.type != :chat # If someone comes or goes, reload the list.
              end
            rescue => e
              say "An error occured with Campfire: #{e}"
            end
          end
        rescue StandardError => e
          raise e
        end
      end
      
      def is_me?(user)
        user.id == me.id
      end
      
      def me
        @me ||= CeilingCat::User.new(@connection.campfire.me[:id], :id => @connection.campfire.me[:id], :role => @connection.campfire.me[:type])
      end
      
      def users_in_room(opts={})
        if opts[:reload] || @users_in_room.nil?
          puts "Requesting user list"
          @users_in_room = @campfire_room.users
        end

        @users_in_room.find_all do |user|
          unless is_me?(CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type]))
            if opts[:type].present?
              if user[:type].to_s.downcase == opts[:type].downcase
                CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
              end
            else
              CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
            end
          end
        end
      end
            
      def say(something_to_say)
        something_to_say = [something_to_say] unless something_to_say.is_a?(Array)

        something_to_say.each do |line|
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
          # logger.info "Leaving room"
          @room.leave if @room
          # logger.info "Reloading config"
          # config(true)
          # raise ReloadException.new("Rejoin room please, ceiling cat")
        end
      end
    end
  end
end