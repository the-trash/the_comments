# TheComments

[![Gem Version](https://badge.fury.io/rb/the_comments.png)](http://badge.fury.io/rb/the_comments) | [![Build Status](https://travis-ci.org/the-teacher/the_comments.png?branch=master)](https://travis-ci.org/the-teacher/the_comments) | [![Code Climate](https://codeclimate.com/github/the-teacher/the_comments.png)](https://codeclimate.com/github/the-teacher/the_comments) | [(rubygems)](http://rubygems.org/gems/the_comments)

TheComments - The best Rails gem for blog-style comments

:question: &nbsp; [Why is TheComments better than other gems?](docs/whats_wrong_with_other_gems.md#why-thecomments-is-better-than-others-gems)

### Features

* Threaded comments
* Useful cache counters
* Admin UI for moderation
* Mountable Engine.routes
* Online Support via skype: **ilya.killich**
* [Denormalization](docs/denormalization_and_recent_comments.md) for recent comments
* Production-ready commenting system for Rails 4+
* Designed for preprocessors such as Sanitize, Textile, Markdawn etc.

### :books: &nbsp; [Documentation](docs/documentation.md)

## If you have any questions

Please try playing around with the **[Dummy App](spec/dummy_app)** in the `spec` folder first. An example integration is often better than any documentation! Thanks.

## How to start the dummy app (screencast)

[![Foo](https://raw.github.com/the-teacher/the_comments/master/docs/screencast.jpg)](http://vk.com/video_ext.php?oid=49225742&id=166578209&hash=10be1dba625149bb&hd=3)

## Quick Start Installation

**NB: In the following examples, `Posts` is the model to which comments are being added. For your app, the model might be `Articles` or similar instead.**

### 1. Install Gems 

**Gemfile**

```ruby
gem "the_comments", "~> 2.2.1"

gem 'haml'                # or gem 'slim'
gem 'awesome_nested_set'  # or same gem
```

**Bundle**

```
bundle
```

Don't forget to restart your server!

### 2. Add migrations

```
rake the_comments_engine:install:migrations
```

Will create:

* xxxxx_change_user.rb
* xxxxx_create_comments.rb
* xxxxx_change_commentable.rb

:warning: &nbsp; **Open and change xxxxx_change_commentable.rb migration**

```ruby
class ChangeCommentable < ActiveRecord::Migration
  def change
    # Additional fields to Commentable Models
    # [:posts, :articles, ... ]

    # There is only Post model is commentable
    [:posts].each do |table_name|
      change_table table_name do |t|
        t.integer :draft_comments_count,     default: 0
        t.integer :published_comments_count, default: 0
        t.integer :deleted_comments_count,   default: 0
      end
    end
  end
end
```

**Invoke migrations**

```
rake db:migrate
```

### 3. Code installation

```ruby
rails g the_comments install
```

Will create:

* config/initializers/the_comments.rb
* app/controllers/comments_controller.rb
* app/models/comment.rb
 
:warning: &nbsp; **Open each file and follow the instructions**

### 4. Models modifictions

**app/models/user.rb**

```ruby
class User < ActiveRecord::Base
  include TheComments::User

  has_many :posts

  # IT'S JUST AN EXAMPLE OF ANY ROLE SYSTEM 
  def admin?
    self == User.first
  end

  # YOU HAVE TO IMPLEMENT YOUR ROLE POLICY FOR COMMENTS HERE
  def comments_admin?
    admin?
  end

  def comments_moderator? comment
    id == comment.holder_id
  end
end
```

**app/models/post.rb**

```ruby
class Post < ActiveRecord::Base
  include TheComments::Commentable

  belongs_to :user

  # Denormalization methods
  # Check the documentation for information on advanced usage
  def commentable_title
    "Undefined Post Title"
  end

  def commentable_url
    "#"
  end

  def commentable_state
    "published"
  end
end
```

### 5. Add routes

**config/routes.rb**

```ruby
MyApp::Application.routes.draw do
  root 'posts#index'
  resources :posts

  # ...

  # TheComments routes
  concern   :user_comments,  TheComments::UserRoutes.new
  concern   :admin_comments, TheComments::AdminRoutes.new
  resources :comments, concerns:  [:user_comments, :admin_comments]
end
```

Refer to the [documentation](docs/documentation.md) for more information

### 6. Add to Application Controller

**app/controllers/application_controller.rb**

```ruby
class ApplicationController < ActionController::Base
  include TheComments::ViewToken

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
```

### 7. Install assets

**app/assets/stylesheets/application.css**

```css
/*
 *= require the_comments
*/
```

**app/assets/javascripts/application.js**

```js
//= require the_comments
```

### 8. Example controller code

**app/controllers/posts_controller.rb**

```ruby
def show
  @post     = Post.find params[:id]
  @comments = @post.comments.with_state([:draft, :published])
end
```

### 9. Example view code

**app/views/posts/show.html.haml**

```haml
= render partial: 'the_comments/tree', locals: { commentable: @post, comments_tree: @comments }
```

<hr>

### Common problems

For error with `unpermitted parameters` in webserver output.

Example:

    Unpermitted parameters: commentable_type, commentable_id

    User Load (0.3ms)  SELECT  "users".* FROM "users"  WHERE "users"."id" = 1  ORDER BY "users"."id" ASC LIMIT 1

    Completed 500 Internal Server Error in 8ms

Add the following to your Comments Controller.

    def comment_params
      params
      .require(:comment)
      .permit(:title, :contacts, :raw_content, :parent_id, :commentable_type, :commentable_id)
      .merge(denormalized_fields)
      .merge(request_data_for_comment)
      .merge(tolerance_time: params[:tolerance_time].to_i)
      .merge(user: current_user, view_token: comments_view_token)
    end

See [here](https://github.com/the-teacher/the_comments/issues/34).

<hr>

For errors with `around_validation`.

Example:

    NoMethodError - protected method `around_validation' called for #<StateMachine::Machine:0x007f84148c3c60>:

Create a new file `config/state_machine.rb`.

    # Rails 4.1.0.rc1 and StateMachine don't play nice
    # https://github.com/pluginaweek/state_machine/issues/295

    require 'state_machine/version'

    unless StateMachine::VERSION == '1.2.0'
      # If you see this message, please test removing this file
      # If it's still required, please bump up the version above
      Rails.logger.warn "Please remove me, StateMachine version has changed"
    end

    module StateMachine::Integrations::ActiveModel
      public :around_validation
    end

See [here](https://github.com/pluginaweek/state_machine/issues/295).

<hr>

### Feedback

:speech_balloon: &nbsp; My twitter: [@iam_teacher](https://twitter.com/iam_teacher) &nbsp; &nbsp; &nbsp; hashtag: **#the_comments**

### Acknowledgments

* Anna Nechaeva (my wife) - for love and my happy life
* @tanraya (Andrew Kozlov) - for code review
* @solenko (Anton Petrunich) - for mountable routes
* @pyromaniac (Arkadiy Zabazhanov) - for consulting

<hr>

### MIT License

Copyright (c) 2013 Ilya N. Zykin

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.