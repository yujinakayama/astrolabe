# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asterisk/version'

Gem::Specification.new do |spec|
  spec.name          = 'asterisk'
  spec.version       = Asterisk::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']
  spec.summary       = 'Object-oriented AST for Parser'
  spec.description   = spec.summary
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',       '~> 1.6'
  spec.add_development_dependency 'rake',          '~> 10.3'
  spec.add_development_dependency 'rspec',         '~> 3.0'
  spec.add_development_dependency 'fuubar',        '~> 2.0.0.rc1'
  spec.add_development_dependency 'simplecov',     '~> 0.7'
  spec.add_development_dependency 'rubocop',       '~> 0.24'
  spec.add_development_dependency 'guard-rspec',   '>= 4.2.3', '< 5.0'
  spec.add_development_dependency 'guard-rubocop', '~> 1.0'
  spec.add_development_dependency 'ruby_gntp',     '~> 0.3'
end
