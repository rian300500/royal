# frozen_string_literal: true

module Royal
  module Locking
    class Advisory
      # Used to extract the lower 32-bits of owner IDs.
      # The 2-argument version of `pg_advisory_xact_lock` accepts 32 bit integers,
      # and this ensures we do not overflow that constraint.
      ID_LOBITS_MASK = 0xFFFFFFFF

      # @param owner [ActiveRecord::Base]
      def call(owner)
        owner.transaction(requires_new: true) do
          acquire_advisory_lock_on_owner(owner)
          yield
        end
      end

    private

      # @param owner [ActiveRecord::Base]
      # @return [void]
      def acquire_advisory_lock_on_owner(owner)
        sql = owner.class.sanitize_sql_array([<<-SQL.squish, owner.class.polymorphic_name, owner.id & ID_LOBITS_MASK])
          SELECT pg_advisory_xact_lock(hashtext(?), ?)
        SQL

        owner.class.connection.query(sql)
      end
    end
  end
end
