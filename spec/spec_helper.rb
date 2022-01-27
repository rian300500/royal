# frozen_string_literal: true

require 'royal'

require_relative 'support/database'
require_relative 'support/user'

Royal.configure do |config|
  config.locking = ENV.fetch('ROYAL_LOCKING_MODE', :optimistic).to_sym
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    Database.prepare_database
    User.create_table
  end

  config.around(:each) do |example|
    Database.run_in_transaction { example.run }
  end
end
