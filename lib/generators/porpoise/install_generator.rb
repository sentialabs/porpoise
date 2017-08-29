require 'rails/generators'

module Porpoise
  class InstallGenerator < Rails::Generators::Base
    desc "Install database migration file"

    source_root File.expand_path("../templates", __FILE__)

    copy_file "migration.rb", "db/migrate/porpoise_create_key_value_objects.rb"
  end
end
