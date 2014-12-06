_root_ = File.expand_path('../../',  __FILE__)

require 'state_machine'
require 'state_machine/version'

require 'the_simple_sort'
require 'the_sortable_tree'

require 'the_comments/config'
require 'the_comments/version'

require 'the_viking'
require 'yandex_cleanweb'

module TheComments
  class Engine < Rails::Engine
    config.autoload_paths += Dir["#{ config.root }/app/controllers/concerns/**/"]
    config.autoload_paths += Dir["#{ config.root }/app/models/concerns/**/"]
  end
end

# Loading of concerns
require "#{ _root_ }/app/models/concerns/the_comments/yandex_cleanweb"
require "#{ _root_ }/app/models/concerns/the_comments/akismet"
require "#{ _root_ }/config/routes.rb"

if StateMachine::VERSION.to_f <= 1.2
  puts '~' * 50
  puts 'WARNING!'
  puts '~' * 50
  puts 'TheComments >>> StateMachine patch for Rails 4 will be applied'
  puts
  puts '> private method *around_validation* from StateMachine::Integrations::ActiveModel will be public'
  puts
  puts 'https://github.com/pluginaweek/state_machine/issues/295'
  puts 'https://github.com/pluginaweek/state_machine/issues/251'
  puts '~' * 50
  module StateMachine::Integrations::ActiveModel
    public :around_validation
  end
end
