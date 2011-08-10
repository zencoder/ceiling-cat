module CeilingCat
  module Campfire
    class Room < CeilingCat::Room
      def initialize(opts={})
        super
        @room = @connection.campfire.find_room_by_name(opts[:room_name])
      end
      
      def watch
        setup_interrupts
        begin
          @room.listen do |event|
            begin
              @user = CeilingCat::User.new(event[:user][:name], :id => event[:user][:id], :role => event[:user][:type])
              @body = event[:body]
              @type = event[:type]
              unless is_me?(@user) # Otherwise CC will talk to itself
                super
              end
            rescue
              puts "An error occured with Campfire: #{$!}"
            end
          end
        rescue StandardError => e
          puts e
        end
      end
      
      def is_me?(user)
        user.id == me.id
      end
      
      def me
        @me || CeilingCat::User.new(@connection.campfire.me[:id], :id => @connection.campfire.me[:id], :role => @connection.campfire.me[:type])
      end
      
      def users_in_room
        @room.users
      end
      
      def registered_users_in_room
        @registered_users_in_room = useusers_in_roomrs.find_all do |user| 
          if user[:type].to_s.downcase == 'member' && !is_me?(user[:id])
            CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
          end
        end
        super
      end
      
      def unregistered_users_in_room
        @registered_users_in_room = users_in_room.find_all do |user| 
          if user[:type].to_s.downcase == 'guest'
            CeilingCat::User.new(user[:name], :id => user[:id], :role => user[:type])
          end
        end
        super
      end
      
      def say(something_to_say)
        something_to_say = [something_to_say] unless something_to_say.is_a?(Array)

        something_to_say.each do |line|
          @room.speak(line)
        end
      end
      
      def setup_interrupts
        trap('INT') do
          puts "Leaving room...."
          @room.leave if @room
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