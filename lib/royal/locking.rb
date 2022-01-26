# frozen_string_literal: true

module Royal
  module Locking
    autoload :Advisory, 'royal/locking/advisory'
    autoload :Optimistic, 'royal/locking/optimistic'
    autoload :Pessimistic, 'royal/locking/pessimistic'

    # @param locator [Symbol]
    # @return [#call]
    def self.resolve(locator)
      case locator
      when :advisory then Advisory.new
      when :optimistic then Optimistic.new
      when :pessimistic then Pessimistic.new
      else raise ArgumentError, "Unsupported locking type: #{locator.inspect}"
      end
    end
  end
end
