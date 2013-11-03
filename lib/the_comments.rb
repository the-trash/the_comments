require 'state_machine'
require 'the_sortable_tree'

require 'the_comments/config'
require 'the_comments/version'

module TheComments
  class Engine < Rails::Engine; end
end

# Loading of concerns

# controllers
require "../../app/controllers/concerns/controller"

# models
%w[ comment_states comment user commentable ].each do |concern|
  require "../../app/models/concerns/#{concern}"
end