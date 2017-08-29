require 'rails/generators'
require 'rails/generators/active_record'

module Porpoise
  module Generators
    class InstallGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      migration_template "migration.rb", "db/migrate/porpoise_create_key_value_objects.rb"
    end
  end
end
