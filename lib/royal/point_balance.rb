# frozen_string_literal: true

require 'active_record'

module Royal
  class PointBalance < ActiveRecord::Base
    attr_readonly :owner_id, :owner_type, :amount, :balance, :sequence

    belongs_to :owner, polymorphic: true, optional: false
    belongs_to :pointable, polymorphic: true, optional: true

    validates :amount, numericality: { other_than: 0 }
    validates :reason, length: { maximum: 1000 }

    before_create do
      previous_balance = self.class.latest_for_owner(owner)

      self.sequence = (previous_balance&.sequence || 0) + 1
      self.balance  = (previous_balance&.balance  || 0) + amount
    end

    after_create if: -> { balance.negative? } do
      # Rollback the transaction _after_ the operation to ensure amount
      # was applied against the most recent points balance.
      raise InsufficientPointsError.new(amount, original_balance, reason, pointable)
    end

    # @param owner [ActiveRecord::Base]
    # @return [PointBalance, nil]
    def self.latest_for_owner(owner)
      PointBalance.where(owner: owner).order(:sequence).last
    end

    # @param owner [ActiveRecord::Base]
    def self.with_lock_on_owner(owner, &block)
      Royal.config.locking.call(owner, &block)
    end

    # @param owner [ActiveRecord::Base]
    # @param amount [Integer]
    # @param attributes [Hash] Additional attributes to set on the new record.
    # @return [Integer] Returns the new points balance.
    def self.apply_change_to_points(owner, amount, **attributes)
      with_lock_on_owner(owner) do
        create!(owner: owner, amount: amount, **attributes).balance
      end
    end

    # Returns the balance before this operation.
    #
    # @return [Integer]
    def original_balance
      balance - amount
    end
  end
end
