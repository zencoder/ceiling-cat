module CeilingCat
  class Error < StandardError; end

  # Gem Specific Errors
  class CeilingCatError < CeilingCat::Error; end

  class UnsupportedChatServiceError < CeilingCatError; end

  class NotImplementedError < CeilingCatError; end

  class ReloadException < CeilingCatError; end
end
