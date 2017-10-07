# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'porpoise/version'

Gem::Specification.new do |spec|
  spec.name          = "porpoise"
  spec.version       = Porpoise::VERSION
  spec.authors       = ["Wessel van Heerde"]
  spec.email         = ["wessel.van.heerde@sentia.com"]
  spec.licenses      = ['MIT']
  spec.summary       = "Rails caching with an RDBMS backend. Also a key/value store with a Redis compatible interface backed by an RDBMS."
  spec.homepage      = "https://github.com/sentialabs/porpoise"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2" 
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "simplecov", "~> 0"
  spec.add_development_dependency "appraisal"

  spec.add_dependency 'activerecord', ">= 3.2"
  spec.add_dependency 'activesupport', ">= 3.2"
  spec.add_dependency "rails", ">= 3.2"
end
