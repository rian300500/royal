# frozen_string_literal: true

require 'active_support/concern'

module Royal
  module Points
    extend ActiveSupport::Concern

    included do
      has_many :point_balances, as: :owner, inverse_of: :owner,
                                class_name: 'Royal::PointBalance', dependent: :delete_all
    end

    # Returns the current number of points in the record's balance.
    #
    # @return [Integer]
    def current_points
      point_balances.order(sequence: :desc).limit(1).pluck(:balance).first || 0
    end

    # Adds a number of points to the record's current points balance.
    #
    # @param amount [Integer] The number of points to add to the blance.
    # @param reason [String, nil] An optional reason to store with the balance change.
    # @param pointable [ActiveRecord::Base, nil] An optional record to associate to the balance change.
    # @param allow_negative_balance [Boolean] Whether to allow the balance to go negative.
    # @return [Integer] Returns the new points balance.
    def add_points(amount, allow_negative_balance: amount.positive?, reason: nil, pointable: nil)
      point_balances.apply_change_to_points(
        self, amount, allow_negative_balance: allow_negative_balance, reason: reason, pointable: pointable
      )
    end

    # Subtracts a number of points to the record's current points balance.
    #
    # @param amount [Integer] The number of points to subtract from the balance.
    # @param reason [String, nil] An optional reason to store with the balance change.
    # @param pointable [ActiveRecord::Base, nil] An optional record to associate to the balance change.
    # @param allow_negative_balance [Boolean] Whether to allow the balance to go negative.
    # @return [Integer] Returns the new points balance.
    def subtract_points(amount, allow_negative_balance: false, reason: nil, pointable: nil)
      point_balances.apply_change_to_points(
        self, -amount, allow_negative_balance: allow_negative_balance, reason: reason, pointable: pointable
      )
    end
  end
end
