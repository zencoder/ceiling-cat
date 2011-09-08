module CeilingCat
  module Plugin
    class TWSS < CeilingCat::Plugin::Base
      RESPONSES = ["That's what she said!", "Uh, that's what she said!", "TWSS", "TWSS!"]

      class << self; attr_accessor :threshold; end # add a class attr_accessor for the TWSS threshold
      self.threshold = 0.5

      def handle
        TWSS.threshold = self.class.threshold
        if event.type == :chat && TWSS(body)
          reply RESPONSES[Kernel.rand(RESPONSES.size)]
        end
      end

      def self.description
        "TWSS via Bayes classifier"
      end

      def self.name
        "TWSS"
      end

      def self.public?
        false
      end
    end
  end
end
