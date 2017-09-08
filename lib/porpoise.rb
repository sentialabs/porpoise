require "porpoise/version"

require "active_record"
require "active_support"
require "mysql2"

# Porpoise specific
require "porpoise/key_value_object"
require "porpoise/util"
require "porpoise/key"
require "porpoise/string"
require "porpoise/hash"
require "porpoise/set"
require "active_support/cache/porpoise_store"

module Porpoise
  class << self
    def with_namespace(namespace)
      Thread.current[:namespace] = namespace.to_s
      res = yield
      Thread.current[:namespace] = nil
      res
    end

    def namespace
      Thread.current[:namespace]
    end

    def namespace?
      self.namespace && !self.namespace.blank?
    end

    def key_with_namespace(key)
      self.namespace? ? "#{self.namespace}:#{key}" : key
    end
  end
end
