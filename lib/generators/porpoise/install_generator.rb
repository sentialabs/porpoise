require 'rails/generators'

module Porpoise
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Install database migration file"
    def create_migration_file
      copy_file "migration.rb", "db/migrate/#{Date.today.strftime('%Y%m%d%H%M%S')}_porpoise_create_key_value_objects.rb"
    end
  end
end
