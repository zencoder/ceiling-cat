require 'httparty'
require 'crack'

module CeilingCat
  module Plugin
    class ZencoderStatus < CeilingCat::Plugin::Base      
      def self.commands
        [{:regex => /^!status/i, :name => "!status", :description => "Check the status of Zencoder.", :method => "check"}]
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
        events = []
        Timeout::timeout(5) do
          events = Crack::JSON.parse(HTTParty.get("http://status.zencoder.com/api/events.json").body)
        end
        if events.size > 0
          reply events.collect{|event| "#{event["event"]["title"]} - http://status.zencoder.com/events/#{event["event"]["id"]}"}
        else
          reply "All systems are go - http://status.zencoder.com"
        end
      rescue Timeout::Error => e
        nil
      end
    end
  end
end