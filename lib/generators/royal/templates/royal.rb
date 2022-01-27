# frozen_string_literal: true

Royal.configure do |config|
  # Sets the locking for the points balance ledger.
  #
  # Available modes are:
  #   - :optimistic (default)
  #   - :pessimistic
  #   - :advisory (PostgreSQL only)
  #
  # Most applications should use the default locking mode.
  # For further information about each of the supported modes, see the README file:
  # https://github.com/mintyfresh/royal#concurrency-and-locking
  #
  # config.locking = :optimistic

  # Sets the maximum number of retries when using the optimistic locking mode. (default 10)
  # config.max_retries = 10
end
