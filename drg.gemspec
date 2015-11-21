# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drg/version'

Gem::Specification.new do |spec|
  spec.name          = "drg"
  spec.version       = DRG::VERSION
  spec.authors       = ["Ryan Buckley"]
  spec.email         = ["arebuckley@gmail.com"]
  spec.summary       = %q{A suite of rake tasks to help you test and manage your project}
  spec.description   = %q{A suite of rake tasks that provide enhanced dependency management and automatic spec generation}
  spec.homepage      = "https://github.com/ridiculous/drg"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby_parser', '>= 3.7.0', '< 4.0.0'
  spec.add_dependency 'bundler', '~> 1.10'
  spec.add_dependency 'duck_puncher', '>= 2.0.0', '<= 3.0.0'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'ruby2ruby', '~> 2.2'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.2', '< 4'
end
