# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/gcloud/datastore/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-gcloud-datastore'
  spec.version       = Hanami::Gcloud::Datastore::VERSION
  spec.authors       = ['Leonardo Saraiva']
  spec.email         = ['vyper@maneh.org']

  spec.summary       = %q{Gcloud Datastore Adapter for Hanami::Model}
  spec.description   = %q{Gcloud Datastore Adapter for Hanami::Model}
  spec.homepage      = 'http://github.com/vyper/hanami-gcloud-datastore'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'hanami-model', '~> 0.5'
  spec.add_runtime_dependency 'gcloud',       '~> 0.7.2'

  spec.add_development_dependency 'bundler',  '~> 1.11'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
