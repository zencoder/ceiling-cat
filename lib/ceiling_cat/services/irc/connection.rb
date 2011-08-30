require 'irc-socket'

module CeilingCat
  module IRC
    class Connection < CeilingCat::Connection
      attr_accessor :irc

      def initialize(config)
        super
      end

      def irc
        return @irc if @irc
        server = @server || 'irc.freenode.org'
        port = @port || 6667
        @irc = IRCSocket.new(server)
      end

      def total_user_count
        1000
      end
    end
  end
end
