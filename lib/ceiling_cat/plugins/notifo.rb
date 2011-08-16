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
        [{:command => "notifo", :description => "Send a message with Notifo - '!notifo Hey, get in here!'.", :method => "deliver"},
         {:command => "add notifo users", :description => "Add users to get Notifos - '!add notifo users username1 username2'.", :method => "add_users"},
         {:command => "remove notifo users", :description => "Add users to get Notifos - '!remove notifo users username1 username2'.", :method => "remove_users"},
         {:command => "list notifo users", :description => "List users who get Notifos - '!list notifo users'.", :method => "list_users"}]
      end
      
      def deliver(message=nil)
        message ||= body_without_nick_or_command("notifo")
        if active?
          Array(store["notifo_users"]).each do |user|
            HTTParty.post("https://api.notifo.com/v1/send_notification",
                            :body => { :to => user, :msg => message },
                            :basic_auth => {:username => @api_username, :password => @api_secret})
          end
        end
      end
      
      def active?
        @api_username && @api_secret && Array(store["notifo_users"]).size > 0
      end
      
      def self.name
        "Notifo"
      end
      
      def self.description
        "Sends messages to users with Notifo"
      end
      
      def self.add_users(users)
        store["notifo_users"] ||= []
        store["notifo_users"] = (Array(store["notifo_users"]) + Array(users)).uniq
      end
      
      def add_users
        users = body_without_nick_or_command("add notifo users").split(" ")
        self.class.add_users(users)
        reply "#{users.join(" ")} added to notifo alerts."
      end
      
      def remove_users
        users = body_without_nick_or_command("remove notifo users").split(" ")
        store["notifo_users"] ||= []
        store["notifo_users"] = store["notifo_users"] - users
        reply "#{users.join(" ")} removed from notifo alerts."
      end
      
      def list_users
        messages = []
        messages << "Notifo Users"
        Array(store["notifo_users"]).each{|user| messages << "-- #{user}"}
        reply messages
      end
    end
  end
end
