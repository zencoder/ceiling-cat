require 'tinder'

module CeilingCat
  module Campfire
    class Connection < CeilingCat::Connection
      def initialize(config)
        super
        @config.ssl ||= "true"
      end

      def campfire
        @campfire = Tinder::Campfire.new(self.config.subdomain, :token => self.config.token, :ssl => self.config.ssl)
      end

      def total_user_count
        users = 0
        @campfire.rooms.each do |room|
          users += room.users.size
        end
        users
      end
    end
  end
end