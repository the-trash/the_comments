&larr; &nbsp; [documentation](documentation.md)

## Admin UI installation

### 1. Gems install

**Gemfile**

```ruby
# TheComments base
gem 'the_comments', "~> 2.0"

gem 'haml'                # or gem 'slim'
gem 'awesome_nested_set'  # or same gem

# TheComments Admin UI gems

# pagination
gem 'kaminari'

# bootstrap 3
gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass'
```

**Bundle**

```
bundle
```

### 2. Assets install

**app/assets/stylesheets/admin_ui.css**

```css
/*
*= require bootstrap
*/
```

**app/assets/javascripts/admin_ui.js**

```js
//= require jquery
//= require jquery_ujs

//= require bootstrap
//= require the_comments_manage
```

### 3. Admin layout

You can use following yields to insert TheComments management tools in your Layout.

```haml
= yield :comments_sidebar
= yield :comments_main
```

For example:

```haml
!!! 5
%html(lang="en")
  %head
    %meta(charset="utf-8")
    %meta(http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1")
    %meta(name="viewport" content="width=device-width, initial-scale=1.0")
    %title= content_for?(:title) ? yield(:title) : "Admin Panel"
    %link(href="favicon.ico" rel="shortcut icon")

    = stylesheet_link_tag    :admin_ui
    = javascript_include_tag :admin_ui
    = csrf_meta_tags

  %body
    .container
      .row
        .col-md-12
          %h3= content_for?(:title) ? yield(:title) : "Admin Panel"
      .row
        .col-md-3= yield :comments_sidebar
        .col-md-9= yield :comments_main

    = stylesheet_link_tag "//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css"
```

### 4. Comments controller modifications

by default your comments controller looks like this:

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

You must define protection methods to restrict access to Admin UI for regular users.

### 5. Visit Admin UI

**localhost:3000/comments/manage**
