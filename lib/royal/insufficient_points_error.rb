# frozen_string_literal: true

module Royal
  class InsufficientPointsError < Error
    # @return [Integer]
    attr_reader :amount
    # @return [Integer]
    attr_reader :balance
    # @return [String, nil]
    attr_reader :reason
    # @return [ActiveRecord::Base, nil]
    attr_reader :pointable

    # @param amount [Integer]
    # @param balance [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    def initialize(amount, balance, reason, pointable)
      @amount    = amount
      @balance   = balance
      @reason    = reason
      @pointable = pointable

      super("Insufficient points: #{amount} (balance: #{balance})")
    end
  end
end
