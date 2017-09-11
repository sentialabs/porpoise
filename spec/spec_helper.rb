require 'simplecov'
SimpleCov.start

ENV['rack_env'] = 'test'

require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

require 'active_record'
require 'sqlite3'
require 'porpoise'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.join('spec/support/schema.rb')
