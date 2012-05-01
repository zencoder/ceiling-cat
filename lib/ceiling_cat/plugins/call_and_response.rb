module CeilingCat
  module Plugin
    class CallAndResponse < CeilingCat::Plugin::Base
      def handle
        if !super && event.type == :chat
          if match = self.class.list.find{|car| body =~ Regexp.new(car[:call],true) }
            if Kernel.rand(10) >= (match[:frequency] || 0)
              response = [match[:response]].flatten # Support old responses which are strings, not arrays
              reply response[Kernel.rand(response.size)]
            end
            return nil
          end
        end
      end

      def self.commands
        [{:command => "list calls", :description => "List current calls and their responses", :method => "list"},
         {:command => "add call", :description => "Add a response to display when a phrase is said, split by a | - '!add call I see what you did there... | You caught me! | Oh no I'm busted!'", :method => "add"},
         {:command => "add random call", :description => "Add a response to display a phrase X of every 10 times, split by a | - '!add random call 5 I see what you did there... | You caught me! | Oh no I'm busted!'", :method => "add_random"},
         {:command => "remove call", :description => "Remove a call and response by call '!remove call I see what you did there...'", :method => "remove"}]
      end

      def self.description
        "Watches for certain phrases and inserts a relevant image"
      end

      def self.name
        "Call and Response"
      end

      def self.public?
        false
      end

      def list
        messages = []
        store["call_and_responses"] ||= []
        if store["call_and_responses"].size > 0
          messages << "Current Calls and Responses"
          messages += store["call_and_responses"].collect{|car| "-- #{car[:call]} | #{[car[:response]].flatten.join(" | ")}"} # Support old responses which are strings, not arrays
        else
          messages << "There are no call and responses set up yet! You should add one with '!add call When someone says this | I say this | or this'"
        end
        reply messages
      end

      def add
        message = body_without_nick_or_command("add call")
        call, *response = message.split("|")
        if self.class.add(:call => call.strip,:response => response.map(&:strip))
          reply "Call and Response added."
        else
          reply "Unable to add that call. A call and a response are required, split by a | - '!add call When someone says this | I say this | or this'"
        end
      end

      def add_random
        message = body_without_nick_or_command("add random call")
        x, frequency, call, *response = message.split(/(\d)\s+([^|]+)\|\s+(.+)/)
        if self.class.add(:call => call.strip,:response => response.map(&:strip), :frequency => frequency.to_i)
          reply "Call and Response added."
        else
          reply "Unable to add that call. A frequency, call, and response are required, split by a | - '!add random call 5 When someone says this | I say this | or this'"
        end
      end

      def remove
        self.class.remove(body_without_nick_or_command("remove call"))
        reply "Call removed."
      end

      def self.list
        store["call_and_responses"] ||= []
      end

      def self.add(opts={})
        return false unless opts[:call] && opts[:response]
        store["call_and_responses"] ||= []
        store["call_and_responses"] = (store["call_and_responses"] + [{:call => opts[:call], :response => opts[:response], :frequency => opts[:frequency]}]).uniq
      end

      def self.remove(call)
        store["call_and_responses"] ||= []
        store["call_and_responses"] = store["call_and_responses"].reject{|car| car[:call].downcase == call.downcase }
      end
    end
  end
end
