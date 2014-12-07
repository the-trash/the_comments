_root_ = File.expand_path('../../',  __FILE__)

require 'state_machine'
require 'state_machine/version'

require 'the_simple_sort'
require 'the_notification'
require 'the_sortable_tree'

require 'the_comments/config'
require 'the_comments/version'

require 'the_viking'
require 'yandex_cleanweb'

module TheComments
  class Engine < Rails::Engine; end
end

# Routing cocerns loading
require "#{ _root_ }/config/routes"

# Model concerns loading
%w[ user comment commentable anti_spam akismet yandex_cleanweb ].each do |file_name|
  require "#{ _root_ }/app/models/concerns/the_comments/#{ file_name }"
end

# Controllers concerns loading
%w[ view_token controller manage_actions spam_traps ].each do |file_name|
  require "#{ _root_ }/app/controllers/concerns/the_comments/#{ file_name }"
end

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
