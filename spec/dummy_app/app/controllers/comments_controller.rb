class CommentsController < ApplicationController
  # Define your restrict methods and use them like this:
  #
  # before_action :user_required,      except: [:index, :create]
  # 
  # before_action :owner_required,     only: [:my, :incoming, :edit, :trash]
  # before_action :moderator_required, only: [:update, :to_published, :to_draft, :to_spam, :to_trash]

  layout 'admin'

  include TheComments::Controller

  # Public methods:
  #
  # [:index, :create]

  # Application side methods:
  # Overwrite following default methods if it's need
  # Following methods based on *current_user* helper method
  # Look here: https://github.com/the-teacher/the_comments/blob/master/app/controllers/concerns/the_comments_controller.rb#L62
  #
  # [:my, :incoming, :edit, :trash]

  # You must protect following methods
  # Only comments moderator (holder or admin) can invoke following actions
  #
  # [:update, :to_published, :to_draft, :to_spam, :to_trash]
end