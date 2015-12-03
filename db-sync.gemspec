# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db/sync/version'

Gem::Specification.new do |spec|
  spec.name          = 'db-sync'
  spec.version       = Db::Sync::VERSION
  spec.authors       = ['Vasil Joskov']
  spec.date          = '2015-11-02'

  spec.summary       = 'Databse Synchronization Tool'
  spec.description   = 'Tool for synchronizing static tables across environments.'
  spec.homepage      = 'https://github.com/joskov/db-sync'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
