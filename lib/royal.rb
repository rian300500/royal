# frozen_string_literal: true

require_relative 'royal/version'

require_relative 'royal/error'
require_relative 'royal/insufficient_points_error'
require_relative 'royal/sequence_error'

require_relative 'royal/config'
require_relative 'royal/points'
require_relative 'royal/point_balance'
require_relative 'royal/locking'
require_relative 'royal/transaction'

module Royal
  # @return [Royal::Config]
  def self.config
    @config ||= Royal::Config.new.freeze
  end

  # @return [void]
  def self.configure
    config = Royal::Config.new
    yield(config)

    @config = config.freeze
  end
end
