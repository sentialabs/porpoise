require "porpoise/version"

require "active_record"
require "mysql2"
require "porpoise/key_value_object"

# Utilities
require "porpoise/util"

# Datatypes
require "porpoise/string"
require "porpoise/hash"
require "porpoise/set"

module Porpoise
  include Porpoise::String
  extend Porpoise::String
end
