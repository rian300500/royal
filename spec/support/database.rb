# frozen_string_literal: true

module Database
  CONFIG = {
    'postgres' => {
      'adapter' => 'postgresql',
      'database' => 'royal_test'
    },
    'sqlite3' => {
      'adapter' => 'sqlite3',
      'database' => ':memory:'
    }
  }.freeze

  def self.prepare_database
    create_database
    connect_to_database
    create_points_balance_table
  end

  def self.create_database
    raise "Unknown database: #{database_adapter}" unless CONFIG.key?(database_adapter)

    send("create_#{database_adapter}_database")
  end

  def self.create_postgres_database
    require 'pg'

    conn = PG.connect(dbname: 'postgres')
    conn.exec('CREATE DATABASE royal_test')
  rescue PG::DuplicateDatabase
    # Database already exists
  end

  def self.create_sqlite3_database
    require 'sqlite3'

    # Nothing to do here.
  end

  def self.connect_to_database
    ActiveRecord::Base.establish_connection(CONFIG[database_adapter])
  end

  def self.database_adapter
    @database_adapter ||= ENV.fetch('TEST_DATABASE_ADAPTER', 'sqlite3')
  end

  def self.run_in_transaction
    ActiveRecord::Base.transaction do
      yield
      raise ActiveRecord::Rollback
    end
  end

  def self.create_points_balance_table
    ActiveRecord::Base.connection.create_table(:point_balances, if_not_exists: true) do |t|
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
