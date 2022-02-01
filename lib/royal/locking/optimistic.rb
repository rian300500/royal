# frozen_string_literal: true

module Royal
  module Locking
    class Optimistic
      # @param owner [Royal::PointBalance]
      def call(_owner, &block)
        result = nil

        up_to_max_retries do
          success, result = try_create_record(&block)
          return result if success
        end

        # NOTE: Failed to insert record after maximum number of attempts.
        # This could be caused by too much write contention for the same owner.
        # One possible solution is to acquire a row-level lock on the owner record and retry.
        # Other solutions like advisory locks or sequential processing queues may work better in some situations.
        raise Royal::SequenceError, "Failed to update points: #{result.message}"
      end

    private

      def up_to_max_retries(&block)
        Royal.config.max_retries.times(&block)
      end

      # @return [[Boolean, Object]]
      def try_create_record
        success = true
        result  = nil

        PointBalance.transaction(requires_new: true) do
          result = yield
        rescue ActiveRecord::RecordNotUnique => error
          success = false
          result  = error
          raise ActiveRecord::Rollback
        end

        [success, result]
      end
    end
  end
end
