# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'porpoise/version'

Gem::Specification.new do |spec|
  spec.name          = "porpoise"
  spec.version       = Porpoise::VERSION
  spec.authors       = ["Wessel van Heerde"]
  spec.email         = ["wessel.van.heerde@sentia.com"]

  spec.summary       = "MySQL key/value store with a Redis compatible interface. Store and access objects in a Redis like way using MySQL storage. Don't use for high performance, use for easy multi master clustering."
  spec.homepage      = "https://dev-git.sentia.com/rubygems/porpoise"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'mysql2', '~> 0.4.9'
  spec.add_dependency 'activerecord'
end
