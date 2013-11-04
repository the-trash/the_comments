class CommentsController < ApplicationController
  # layout 'admin'

  # Define your restrict methods and use them like this:
  #
  # before_action :user_required,  except: %w[index create]
  # before_action :owner_required, except: %w[index create]
  # before_action :admin_required, only:   %w[total_draft total_published total_deleted total_spam]
  
  include TheComments::Controller

  # >>> include TheComments::Controller <<<
  # (!) Almost all methods based on *current_user* method
  #
  # 1. Controller's public methods list:
  # You can redifine it for your purposes
  # public
  # %w[ manage index create edit update ]
  # %w[ my_comments my_draft my_published ]
  # %w[ draft published deleted spam ]
  # %w[ to_draft to_published to_deleted to_spam ]
  # %w[ total_draft total_published total_deleted total_spam ]
  #
  #
  # 2. Controller's private methods list:
  # You can redifine it for your purposes
  #
  # private
  # %w[ comment_template comment_partial ]
  # %w[ denormalized_fields request_data_for_comment define_commentable ]
  # %w[ comment_params patch_comment_params ]
  # %w[ ajax_requests_required cookies_required ]
  # %w[ empty_trap_required tolerance_time_required ]

  # KAMINARI pagination:
  # following methods based on gem "kaminari"
  # You should redefine them if you use something else
  #
  # public
  # %w[ manage index edit ]
  # %w[ draft published deleted spam ]
  # %w[ my_comments my_draft my_published ]
  # %w[ total_draft total_published total_deleted total_spam ]
end