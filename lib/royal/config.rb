# frozen_string_literal: true

module Royal
  class Config
    DEFAULT_LOCKING = :optimistic

    # The configured locking mechanism for the points balance ledger.
    #
    # @return [#call]
    attr_reader :locking

    def initialize
      self.locking = DEFAULT_LOCKING
    end

    # @param locator [Symbol]
    # @return [void]
    def locking=(locator)
      @locking = Royal::Locking.resolve(locator)
    end
  end
end
