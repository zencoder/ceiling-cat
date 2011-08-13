require 'tinder'

module CeilingCat
  module Campfire
    class Connection < CeilingCat::Connection
      def initialize(config)
        @config=config
        @config.ssl ||= "true"
      end
      
      def campfire
        @campfire = Tinder::Campfire.new(self.config.username, :token => self.config.token, :ssl => self.config.ssl)
      end
    end
  end
end