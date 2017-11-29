# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "svg_drawer/version"

Gem::Specification.new do |spec|
  spec.name          = 'svg_drawer'
  spec.version       = SvgDrawer::VERSION
  spec.authors       = ['Simeon Manolov']
  spec.email         = ['s.manolloff@gmail.com']
  spec.summary       = 'A ruby gem for building table-based SVG layouts'
  spec.homepage      = 'https://github.com/smanolloff/svg_drawer'
  spec.license       = 'MIT'

  spec.require_paths = ['lib']
  spec.files = Dir.glob('lib/**/*') + %w[LICENSE.txt svg_drawer.gemspec]

  spec.add_dependency 'rasem', '~> 0.7'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
