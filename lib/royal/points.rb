# frozen_string_literal: true

require 'active_support/concern'

module Royal
  module Points
    extend ActiveSupport::Concern

    included do
      has_many :point_balances, as: :owner, inverse_of: :owner,
                                        class_name: 'Royal::PointBalance', dependent: :delete_all
    end

    # @return [Integer]
    def current_points
      point_balances.order(sequence: :desc).limit(1).pluck(:balance).first || 0
    end

    # @param amount [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [Integer] Returns the new points balance.
    def add_points(amount, reason: nil, pointable: nil)
      point_balances.apply_change_to_points(self, amount, reason: reason, pointable: pointable)
    end

    # @param amount [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [Integer] Returns the new points balance.
    def subtract_points(amount, reason: nil, pointable: nil)
      point_balances.apply_change_to_points(self, -amount, reason: reason, pointable: pointable)
    end
  end
end
