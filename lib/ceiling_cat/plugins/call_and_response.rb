module CeilingCat
  module Plugin
    class CallAndResponse < CeilingCat::Plugin::Base
      def handle
        if event.type == :chat
          super
          if match = self.class.list.find{|car| body =~ Regexp.new(Regexp.escape(car[:call]),true) }
            reply match[:url]
            return nil
          end
        end
        
      end

      def self.commands
        [{:command => "list calls", :description => "List current calls and their responses", :method => "list"},
         {:command => "add call", :description => "Add an response to display when a phrase is said, split by a | - '!add call I see what you did there... | You caught me!'", :method => "add"},
         {:command => "remove call", :description => "Remove an call and response by call '!remove call I see what you did there...'", :method => "remove"}]
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
          messages += store["call_and_responses"].collect{|car| "-- #{car[:call]} | #{car[:response]}"}
        else
          messages << "There are no call and respones set up yet! You should add one with '!add call When someone says this | I say this'"
        end
        reply messages
      end

      def add
        message = body_without_nick_or_command("add call").split
        call, response = message.split("|")
        if self.class.add(:call => call.strip,:response => response.strip)
          reply "Call and Response added."
        else
          reply "Unable to add that call. A call and a response are required, split by a | - 'When someones says this | I say this'"
        end
      end

      def remove
        self.class.remove(body_without_nick_or_command("remove image phrase"))
        reply "Call removed."
      end

      def self.list
        store["call_and_responses"] ||= []
      end

      def self.add(opts={})
        return false unless opts[:call] && opts[:response]
        store["call_and_responses"] ||= []
        store["call_and_responses"] = (store["call_and_responses"] + [{:call => opts[:call], :response => opts[:response]}]).uniq
      end

      def self.remove(phrase)
        store["call_and_responses"] ||= []
        store["call_and_responses"] = store["call_and_responses"].reject{|car| car[:call].downcase == call.downcase }
      end
    end
  end
end
