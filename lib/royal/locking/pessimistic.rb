# frozen_string_literal: true

module Royal
  module Locking
    class Pessimistic
      # @param owner [ActiveRecord::Base]
      def call(owner, &block)
        owner.transaction(requires_new: true) do
          # NOTE: Avoid using `lock!` to prevent reloading the record from DB.
          # We don't need any updated state, just exclusive use of the record.
          owner.class.where(id: owner).lock(true).take!
          yield
        end
      end
    end
  end
end
