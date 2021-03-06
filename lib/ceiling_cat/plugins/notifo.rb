require 'httparty'

module CeilingCat
  class NotifoNotConfiguredError < CeilingCatError; end

  module Plugin
    class Notifo < CeilingCat::Plugin::Base
      def self.commands
        [{:command => "notifo", :description => "Send a message with Notifo - '!notifo user: Hey, get in here!'. 'user:' is optional, and will go to everyone if not passed.", :method => "deliver"},
         {:command => "add notifo users", :description => "Add users to get Notifos - '!add notifo users username1 username2'.", :method => "add_users"},
         {:command => "remove notifo users", :description => "Add users to get Notifos - '!remove notifo users username1 username2'.", :method => "remove_users"},
         {:command => "list notifo users", :description => "List users who get Notifos - '!list notifo users'.", :method => "list_users"}]
      end

      def deliver(full_message=nil)
        body_parts = (full_message || body_without_nick_or_command("notifo")).scan(/^((\w+):)?(.+)$/)[0]
        message = body_parts[2].strip
        user = body_parts[1]

        users = user ? Array(user.strip) : Array(store["notifo_users"])
        users.each do |user|
          CeilingCat::Plugin::Notifo.deliver(user,message)
        end
      end

      def self.deliver(user,message)
        if active?
          HTTParty.post("https://api.notifo.com/v1/send_notification",
                          :body => { :to => user, :msg => message },
                          :basic_auth => {:username => store["notifo_credentials"][:username], :password => store["notifo_credentials"][:api_secret]})
        else
          raise NotifoNotConfiguredError
        end
      end

      def self.active?
        if store["notifo_credentials"] && store["notifo_credentials"][:username].present? && store["notifo_credentials"][:api_secret].present?
          true
        else
          false
        end
      end

      def active?
        self.class.active?
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

      def self.remove_users(users)
        store["notifo_users"] ||= []
        store["notifo_users"] = (Array(store["notifo_users"]) - Array(users)).uniq
      end

      def self.set_credentials(username, api_secret)
        store["notifo_credentials"] = {:username => username, :api_secret => api_secret}
      end

      def add_users
        users = body_without_nick_or_command("add notifo users").split(" ")
        self.class.add_users(users)
        reply "#{users.join(" ")} added to notifo alerts."
      end

      def remove_users
        users = body_without_nick_or_command("remove notifo users").split(" ")
        self.class.remove_users(users)
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
