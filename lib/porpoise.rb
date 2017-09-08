require "porpoise/version"

require "active_record"
require "active_support"
require "mysql2"

require "porpoise/key_value_object"
require "active_support/cache/porpoise_store"

# Utilities
require "porpoise/util"
require "porpoise/key"

# Datatypes
require "porpoise/string"
require "porpoise/hash"
require "porpoise/set"

module Porpoise
  class << self
    def with_namespace(namespace)
      Thread.current[:namespace] = namespace
      yield
    end

    def namespace
      Thread.current[:namespace]
    end

    def namespace?
      self.namespace && !self.namespace.blank?
    end
  end
end
