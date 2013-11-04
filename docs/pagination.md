&larr; &nbsp; [documentation](documentation.md)

## I want not to use kaminari for Admin UI

By default we use Kaminari pagination for Admin UI.

But you can change this. For example, your **comments_controller.rb** looks like this:

**app/controllers/comments_controller.rb**

```ruby
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
```

There is we can see comments about kaminari. So, we can try to change it.

There is example how it can be in your real app:

```ruby
class CommentsController < ApplicationController
  layout 'admin'

  before_action :user_required,  except: %w[index create]
  before_action :owner_required, except: %w[index create]
  before_action :admin_required, only:   %w[total_draft total_published total_deleted total_spam]
  
  include TheComments::Controller

  public

    def index
      @comments = ::Comment.with_state(:published).recent.super_paginator(params)
      render comment_template(:index)
    end

    def manage
      @comments = current_user.comcoms.active.recent.super_paginator(params)
      render comment_template(:manage)
    end

    def my_comments
      @comments = current_user.my_comments.active.recent.super_paginator(params)
      render comment_template(:my_comments)
    end

    def edit
      @comments = current_user.comcoms.where(id: params[:id]).super_paginator(params)
      render comment_template(:manage)
    end

    %w[draft published deleted].each do |state|
      define_method "#{state}" do
        @comments = current_user.comcoms.with_state(state).recent.super_paginator(params)
        render comment_template(:manage)
      end

      define_method "total_#{state}" do
        @comments = ::Comment.with_state(state).recent.super_paginator(params)
        render comment_template(:manage)
      end

      unless state == 'deleted'
        define_method "my_#{state}" do
          @comments = current_user.my_comments.with_state(state).recent.super_paginator(params)
          render comment_template(:my_comments)
        end
      end
    end

    def spam
      @comments = current_user.comcoms.where(spam: true).recent.super_paginator(params)
      render comment_template(:manage)
    end

    def total_spam
      @comments = ::Comment.where(spam: true).recent.super_paginator(params)
      render comment_template(:manage)
    end
end
```