# frozen_string_literal: true

module Royal
  module Locking
    class Advisory
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
        sql = owner.class.sanitize_sql_array([<<-SQL.squish, owner.class.polymorphic_name, owner.id])
          SELECT pg_advisory_xact_lock(hashtext(?), ?)
        SQL

        owner.class.connection.query(sql)
      end
    end
  end
end
