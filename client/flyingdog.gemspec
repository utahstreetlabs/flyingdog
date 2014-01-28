# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'flying_dog', 'version'), __FILE__)

Gem::Specification.new do |s|
  s.name = 'flyingdog'
  s.version = FlyingDog::VERSION.dup
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.authors = ['Rob Zuber']
  s.description = 'FlyingDog service client'
  s.email = ['rob@copious.com']
  s.homepage = 'http://github.com/utahstreetlabs/flyingdog'
  s.rdoc_options = ['--charset=UTF-8']
  s.summary = "A client library for the FlyingDog service"
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files -- lib/*`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rspec')
  s.add_development_dependency('gemfury')
  s.add_runtime_dependency('ladon', '~> 4.0')
end
