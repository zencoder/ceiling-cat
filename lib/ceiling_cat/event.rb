module CeilingCat
  class Event
    attr_accessor :room, :body, :user, :type, :time

    def initialize(room, body,user,opts={})
      @room = room
      @body = body
      @user = user
      @type = opts[:type]
      @time = opts[:time] || Time.now
    end
    
    def handle
      puts "#{user.short_name} says: #{@body} at #{@time}"
      # @room.say "What up #{user}"
      @room.plugins.each do |plugin|
        begin
          response = plugin.new(self).handle
          break if response == true
        rescue => e
          @room.say("Whoops - there was a problem with a plugin")
        end
      end
    end
  end
end