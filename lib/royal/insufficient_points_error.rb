# frozen_string_literal: true

module Royal
  class InsufficientPointsError < Error
    # @return [Integer]
    attr_reader :amount
    # @return [Integer]
    attr_reader :balance
    # @return [String, nil]
    attr_reader :reason

    # @param amount [Integer]
    # @param balance [Integer]
    # @param reason [String, nil]
    def initialize(amount, balance, reason)
      @amount  = amount
      @balance = balance
      @reason  = reason

      super("Insufficient points: #{amount} (balance: #{balance})")
    end
  end
end
