# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'the_comments/version'

Gem::Specification.new do |gem|
  gem.name          = "the_comments"
  gem.version       = TheComments::VERSION
  gem.authors       = ["Ilya N. Zykin"]
  gem.email         = ["zykin-ilya@ya.ru"]
  gem.description   = %q{ Comments with threading for Rails 4.2+ }
  gem.summary       = %q{ the_comments by the-teacher }
  gem.homepage      = "https://github.com/the-teacher/the_comments"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'the_comments_base'
  gem.add_dependency 'the_comments_manager'
  gem.add_dependency 'the_comments_subscriptions'
  gem.add_dependency 'the_comments_antispam_services'
end
