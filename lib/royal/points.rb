# frozen_string_literal: true

require 'active_support/concern'

module Royal
  module Points
    extend ActiveSupport::Concern

    included do
      has_many :loyalty_point_balances, as: :owner, inverse_of: :owner,
                                        class_name: 'Royal::PointBalance', dependent: :destroy
    end

    # @return [Integer]
    def loyalty_points
      loyalty_point_balances.order(:sequence).last&.balance || 0
    end

    # @param points [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [Integer] Returns the new points balance.
    def add_loyalty_points(amount, reason: nil, pointable: nil)
      loyalty_point_balances.apply_change_to_points(amount, reason: reason, pointable: pointable)
    end

    # @param points [Integer]
    # @param reason [String, nil]
    # @param pointable [ActiveRecord::Base, nil]
    # @return [Integer] Returns the new points balance.
    def spend_loyalty_points(amount, reason: nil, pointable: nil)
      loyalty_point_balances.apply_change_to_points(-amount, reason: reason, pointable: pointable)
    end
  end
end
