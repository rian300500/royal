# frozen_string_literal: true

module Royal
  module Locking
    class Optimistic
      # @param owner [Royal::PointBalance]
      def call(_owner)
        retries ||= 0

        PointBalance.transaction(requires_new: true) do
          yield
        rescue ActiveRecord::RecordNotUnique => error
          raise error unless error.message.include?(PointBalance.sequence_unique_index_name)

          retry if (retries += 1) < MAX_RETRIES

          # NOTE: Failed to insert record after maximum number of attempts.
          # This could be caused by too much write contention for the same owner.
          # One possible solution is to acquire a row-level lock on the owner record and retry.
          # Other solutions like advisory locks or sequential processing queues may work better in some situations.
          raise Royal::SequenceError, "Failed to update points: #{error.message}"
        end
      end
    end
  end
end
