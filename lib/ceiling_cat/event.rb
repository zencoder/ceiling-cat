module CeilingCat
  class Event
    attr_accessor :room, :body, :user, :type, :time

    def initialize(room, body,user,opts={})
      @room = room
      @body = body.to_s.strip
      @user = user
      @type = opts[:type]
      @time = opts[:time] || Time.now
    end

    def handle
      @room.plugins.each do |plugin|
        puts "running #{plugin}"
        begin
          response = plugin.new(self).handle
          break if response.present?
        rescue => e
          @room.say("Whoops - there was a problem with #{plugin}: #{e}")
        end
      end
    end

    def type # assume that all messages are just text unless the specific room type overrides it.
      @type || :chat
    end
  end
end