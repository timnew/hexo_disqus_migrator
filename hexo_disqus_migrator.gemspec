# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hexo_disqus_migrator/version'

Gem::Specification.new do |spec|
  spec.name          = 'hexo_disqus_migrator'
  spec.version       = Migrator::VERSION
  spec.authors       = ['TimNew']
  spec.email         = ['timnew.wti@gmail.com']
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'commander', '~> 4.2.0'
  spec.add_dependency 'terminal-table', '~> 1.4.5'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
