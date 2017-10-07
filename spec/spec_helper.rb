require 'simplecov'
SimpleCov.start do
  add_filter %r{^/spec/}
end

ENV['rack_env'] = 'test'

require 'active_record'
require 'sqlite3'
require 'porpoise'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.join('spec/support/schema.rb')
