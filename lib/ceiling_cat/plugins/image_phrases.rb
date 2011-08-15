module CeilingCat
  module Plugin
    class ImagePhrases < CeilingCat::Plugin::Base
      # See lib/ceiling_cat/plugins/base.rb for the methods available by default.
      # Plugins are run in the order they are listed in the Chatfile.
      # When a plugin returns anything other than nil the plugin execution chain is halted.
      # If you want your plugin to do something but let the remaining plugins execute, return nil at the end of your methods.

      # If you just need to respond to messages in chat you can remove this (or leave it alone).
      # If you want to handle other events, such as room entrances and exits, use this.
      # def handle
      #  super
      # end

      def handle
        if event.type == :chat
          super
          if match = self.class.list.find{|phrase| body =~ Regexp.new(Regexp.escape(phrase[:phrase]),true) }
            reply match[:url]
            return nil
          end
        end
        
      end

      def self.commands
        [{:command => "list image phrases", :description => "List current image phrases", :method => "list"},
         {:command => "add image phrase", :description => "Add an image to display when a phrase is said - '!add image phrase http://example.com/foo.jpg I see what you did there...'", :method => "add"},
         {:command => "remove image phrase", :description => "Remove an image/phrase pair by phrase '!remove image phrase I see what you did there...'", :method => "remove"}]
      end

      def self.description
        "Watches for certain phrases and inserts a relevant image"
      end

      def self.name
        "Image Phrases"
      end

      def self.public?
        false
      end

      def list
        reply "Current Image Phrases"
        reply self.class.list.collect{|ip| "-- #{ip[:phrase]}"}
      end

      def add
        message = body_without_nick_or_command("add image phrase").split
        url = message.shift
        phrase = message.join(" ")
        if self.class.add(:phrase => phrase,:url => url)
          reply "Image Phrase added."
        else
          reply "Unable to add that Image Phrase. A URL and a Phrase are required - 'http://example.com My phrase'"
        end
      end

      def remove
        self.class.remove(body_without_nick_or_command("remove image phrase"))
        reply "Image Phrase removed."
      end

      def self.list
        store["image_phrases"] ||= []
      end

      def self.add(opts={})
        return false unless opts[:phrase] && opts[:url]
        store["image_phrases"] ||= []
        store["image_phrases"] = (store["image_phrases"] + [{:phrase => opts[:phrase], :url => opts[:url]}]).uniq
      end

      def self.remove(phrase)
        store["image_phrases"] ||= []
        store["image_phrases"] = store["image_phrases"].reject{|ip| ip[:phrase].downcase == phrase.downcase }
      end
    end
  end
end
