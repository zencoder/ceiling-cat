require 'httparty'
require 'crack'

module CeilingCat
  module Plugin
    class ZencoderStatus < CeilingCat::Plugin::Base
      def self.commands
        [{:command => "status", :description => "Check the status of Zencoder.", :method => "check", :public => true}]
      end

      def self.description
        "Check the status of Zencoder"
      end

      def self.name
        "Zencoder Status"
      end

      def self.public?
        true
      end

      def check
        messages = []
        events = []
        Timeout::timeout(5) do
          events = Crack::JSON.parse(HTTParty.get("http://status.zencoder.com/api/events.json").body)
        end
        if events.size > 0
          messages << "Currently known Zencoder isses:"
          messages << events.collect{|event| "#{event["event"]["title"]} - http://status.zencoder.com/events/#{event["event"]["id"]}"}
        else
          messages << "All systems are go - http://status.zencoder.com"
        end
        reply messages
      rescue Timeout::Error => e
        nil
      end
    end
  end
end