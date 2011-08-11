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
                # if event.type != :chat # If someone comes or goes, reload the list.
                #   @registered_users_in_room = registered_users_in_room(true) if user.is_registered?
                #   @unregistered_users_in_room = unregistered_users_in_room(true) if user.is_guest?
                # end
              end
            rescue
              say "An error occured with Campfire: #{$!}"
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
      
      def users_in_room
        @campfire_room.users
      end
      
      def registered_users_in_room(reload=false)
        puts "child class"
        # return @registered_users_in_room unless (@registered_users_in_room.nil? || reload)
        @registered_users_in_room = users_in_room.find_all do |user| 
          if user[:type].to_s.downcase == 'member' && !is_me?(CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type]))
            CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
          end
        end
        super
      end
      
      def unregistered_users_in_room(reload=false)
        # return @unregistered_users_in_room unless (@unregistered_users_in_room.nil? || reload)
        @unregistered_users_in_room = users_in_room.find_all do |user| 
          if user[:type].to_s.downcase == 'guest'
            CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
          end
        end
        super
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
          @campfire_room.leave if @room
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