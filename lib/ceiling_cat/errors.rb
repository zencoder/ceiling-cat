module CeilingCat
  class Error < StandardError

    def initialize(message)
      super message
    end
  end

  # Gem Specific Errors
  class CeilingCatError < StandardError; end

  class UnsupportedChatServiceError < CeilingCatError; end

  class NotImplementedError < CeilingCatError; end

  class ReloadException < CeilingCatError; end
end
