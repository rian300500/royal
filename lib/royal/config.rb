# frozen_string_literal: true

module Royal
  class Config
    DEFAULT_LOCKING     = :optimistic
    DEFAULT_MAX_RETRIES = 10

    # The configured locking mechanism for the points balance ledger.
    #
    # @return [#call]
    attr_reader :locking
    # @return [Integer]
    attr_reader :max_retries

    def initialize
      self.locking     = DEFAULT_LOCKING
      self.max_retries = DEFAULT_MAX_RETRIES
    end

    # @param locator [Symbol]
    # @return [void]
    def locking=(locator)
      @locking = Royal::Locking.resolve(locator)
    end

    # @param max_retries [Integer]
    # @return [void]
    def max_retries=(max_retries)
      raise ArgumentError, 'Max retries must be an Integer' unless max_retries.is_a?(Integer)
      raise ArgumentError, 'Max retries must be positive' unless max_retries.positive?

      @max_retries = max_retries
    end
  end
end
