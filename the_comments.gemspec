# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'the_comments/version'

Gem::Specification.new do |gem|
  gem.name          = "the_comments"
  gem.version       = TheComments::VERSION
  gem.authors       = ["Ilya N. Zykin"]
  gem.email         = ["zykin-ilya@ya.ru"]
  gem.description   = %q{TODO: Nested Comments}
  gem.summary       = %q{TODO: Nested Comments form TheTeacher}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # gem.add_dependency 'awesome_nested_set'
  # gem.add_dependency 'the_sortable_tree'
  # gem.add_dependency 'state_machine'
  # gem.add_dependency 'sanitize'
end
