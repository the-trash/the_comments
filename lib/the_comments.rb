require 'state_machine'
require 'the_sortable_tree'

require 'the_comments/config'
require 'the_comments/version'

module TheComments
  class Engine < Rails::Engine; end
end

# Loading of concerns

# controllers
require File.expand_path('../../app/controllers/concerns/controller.rb', __FILE__)

# models
%w[ comment_states comment user commentable ].each do |concern|
  require File.expand_path("../../app/models/concerns/#{concern}.rb", __FILE__)
end