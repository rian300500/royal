# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Royal
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      def create_migration
        migration_template 'create_point_balances.rb.erb', 'db/migrate/create_point_balances.rb'
      end

    private

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails.version >= '5.0.0'
      end
    end
  end
end
