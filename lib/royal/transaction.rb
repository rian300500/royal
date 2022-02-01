# frozen_string_literal: true

module Royal
  class Transaction
    Operation = Struct.new(:owner, :amount, :reason, :pointable) do
      # @return [void]
      def perform
        owner.add_points(amount, reason: reason, pointable: pointable)
      end

      # Used to ensure a deterministic order of operations in a transaction to avoid deadlocks.
      #
      # @return [Array]
      def sorting_key
        [owner.class.polymorphic_name, owner.id, -amount]
      end
    end

    def initialize
      @operations = []
    end

    # @param owner [ActiveRecord::Base]
    # @param amount [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [self]
    def add_points(owner, amount, reason: nil, pointable: nil)
      @operations << Operation.new(owner, amount, reason, pointable).freeze

      self
    end

    # @param owner [ActiveRecord::Base]
    # @param amount [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [self]
    def subtract_points(owner, amount, reason: nil, pointable: nil)
      add_points(owner, -amount, reason: reason, pointable: pointable)
    end

    # @return [self]
    def call
      PointBalance.transaction(requires_new: true) do
        @operations.sort_by(&:sorting_key).each(&:perform)
      end

      self
    end
  end
end
