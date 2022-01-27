# frozen_string_literal: true

require 'rails/generators'

module Royal
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'royal.rb', 'config/initializers/royal.rb'
      end
    end
  end
end
