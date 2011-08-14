require 'httparty'

module CeilingCat
  module Plugin
    class Notifo < CeilingCat::Plugin::Base
      attr_accessor :api_username, :api_secret, :users
      
      def initialize(opts={})
        super
        @api_username = room.config.notifo[:api_username]
        @api_secret = room.config.notifo[:api_secret]
        @users = room.config.notifo[:users]
      end
      
      def self.commands
        [{:regex => "notifo", :name => "notifo", :description => "Send a message with Notifo - '!notifo Hey, get in here!'.", :method => "deliver"}]
      end
      
      def deliver(message=nil)
        message ||= body_without_command(commands.first[:regex])
        if active?
          @users.each do |user|
            HTTParty.post("https://api.notifo.com/v1/send_notification",
                            :body => { :to => user, :msg => message },
                            :basic_auth => {:username => @api_username, :password => @api_secret})
          end
        end
      end
      
      def active?
        @api_username && @api_secret && @users.size > 0
      end
      
      def self.name
        "Notifo"
      end
      
      def self.description
        "Sends messages to users with Notifo"
      end
    end
  end
end