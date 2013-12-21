# TheComments

[![Gem Version](https://badge.fury.io/rb/the_comments.png)](http://badge.fury.io/rb/the_comments) | [![Build Status](https://travis-ci.org/the-teacher/the_comments.png?branch=master)](https://travis-ci.org/the-teacher/the_comments) | [![Code Climate](https://codeclimate.com/github/the-teacher/the_comments.png)](https://codeclimate.com/github/the-teacher/the_comments) | [(rubygems)](http://rubygems.org/gems/the_comments)

TheComments - probably, best commenting system for Rails

:question: &nbsp; [Why TheComments is better than others gems?](docs/whats_wrong_with_other_gems.md#why-thecomments-is-better-than-others-gems)

### Main features

* Threaded comments
* Useful cache counters
* Admin UI for moderation
* Mountable Engine.routes
* Online Support via skype: **ilya.killich**
* [Denormalization](docs/denormalization_and_recent_comments.md) for Recent comments
* Production-ready commenting system for Rails 4+
* Designed for preprocessors Sanitize, Textile, Markdawn etc.

### :books: &nbsp; [Documentation](docs/documentation.md)

## If you have any questions

Please before ask anything try to launch and play with **[Dummy App](spec/dummy_app)** in spec folder. Maybe example of integration will be better than any documentation. Thank you!

## How to start dummy app (screencast)

[![Foo](https://raw.github.com/the-teacher/the_comments/master/docs/screencast.jpg)](http://vk.com/video_ext.php?oid=49225742&id=166578209&hash=10be1dba625149bb&hd=3)

## Quick Start Installation

### 1. Gems install

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

### 2. Migrations install

**Copy migrations**

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

### 3. Code install

```ruby
rails g the_comments install
```

Will create:

* config/initializers/the_comments.rb
* app/controllers/comments_controller.rb
* app/models/comment.rb
 
:warning: &nbsp; **Open each file and follow an instructions**

### 4. Models modifictions

**app/models/user.rb**

```ruby
class User < ActiveRecord::Base
  include TheComments::User

  has_many :posts

  def admin?
    self == User.first
  end

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
  # Please, read about advanced using
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

Please, read [documentation](docs/documentation.md) to learn more

### 6. Controller's addon

```ruby
class ApplicationController < ActionController::Base
  include TheComments::ViewToken

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
```

### 7. Assets install

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

### 8. Controller code example

**app/controllers/posts_controllers.rb**

```ruby
def show
  @post     = Post.find params[:id]
  @comments = @post.comments.with_state([:draft, :published])
end
```

### 9. View code example

**app/views/posts/show.html.haml**

```haml
= render partial: 'the_comments/tree', locals: { commentable: @post, comments_tree: @comments }
```

<hr>

### Feedback

:speech_balloon: &nbsp; My twitter: [@iam_teacher](https://twitter.com/iam_teacher) &nbsp; &nbsp; &nbsp; hashtag: **#the_comments**

### Acknowledgment

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
