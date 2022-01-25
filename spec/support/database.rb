# frozen_string_literal: true

module Database
  def self.prepare_database
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    create_points_balance_table
  end

  def self.run_in_transaction
    ActiveRecord::Base.transaction do
      yield
      raise ActiveRecord::Rollback
    end
  end

  def self.create_points_balance_table
    ActiveRecord::Base.connection.create_table(:point_balances) do |t|
      t.belongs_to :owner, polymorphic: true, null: false
      t.belongs_to :pointable, polymorphic: true, null: true
      t.string     :reason, null: true
      t.integer    :amount, null: false
      t.integer    :balance, null: false
      t.integer    :sequence, null: false
      t.timestamps

      t.index %i[owner_id owner_type sequence], unique: true
    end
  end
end
