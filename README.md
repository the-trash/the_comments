# TheComments 0.0.9

TheComments - comments tree for your web project.

### Main features

* **Comments tree** (via [TheSortableTree](https://github.com/the-teacher/the_sortable_tree) custom helper)
* **No captcha!** Tricks and traps for SpamBots instead Captcha
* **IP** and **User Agent** black lists
* Useful **Cache counters** for Users and Commentable objects
* Designed for external content filters ( **sanitize**, **RedCloth**, **Markdown**)
* Open comments with moderation
* Creator of comments can see his comments via **view_token** ( _view token_ stored with cookies)
* Denormalization of commentable objects. We store **commentable_title** and **commentable_url** in each comment, for fast access to commentable object

### Requires

```ruby
gem 'awesome_nested_set'
gem 'the_sortable_tree'
gem 'state_machine'
```

### Anti Spam system

User agent must have:

* Cookies support
* JavaScript and Ajax support

Usually spambot not support cookies and JavaScript

Comment form have:

* fake (hidden) email fields

Usually spam bot puts data in fake inputs

## Installation

```ruby
gem 'the_comments'
```

**bundle**

```ruby
bundle exec rails g model comment --migration=false
bundle exec rails g model ip_black_list --migration=false
bundle exec rails g model user_agent_black_list --migration=false

bundle exec rake the_comments_engine:install:migrations
```

**bundle exec rake db:migrate**

#### User Model

```ruby
class User < ActiveRecord::Base
  has_many :comments
  has_many :comcoms, class_name: :Comment, foreign_key: :holder_id
  
  # denormalization for commentable objects (title)
  def commentable_title
    self.login
  end

  # denormalization for commentable objects (url|path)
  def commentable_path
    [self.class.to_s.tableize, self.login].join('/')
  end

  # your implementation of role policy for comments moderators
  def comments_moderator? (commentable)
    self.admin? || (commentable.holder_id == self.id)
  end

end
```

**comcoms** - commentable comments. Set of all comments of all owned commentable objects of this user

#### Commentable Model (Page, Blog, Article, User ...)

```ruby
class Blog < ActiveRecord::Base
  has_many :comments, as: :commentable

  # denormalization for commentable objects
  def commentable_title
    self.title
  end

  # denormalization for commentable objects
  def commentable_path
    [self.class.to_s.tableize, self.slug_id].join('/')
  end
end
```

#### Comment Model

```ruby
class Comment < ActiveRecord::Base
  include TheCommentModel
end
```

#### Commentable controller

```ruby
class BlogsController < ApplicationController
  include TheCommentsController::Cookies
  include TheCommentsController::ViewToken

  def show
    @blog     = @blog.where(id: params[:id]).with_states(:published).first
    @comments = @blog.comments.with_state([:draft, :published]).nested_set
  end
end
```

#### View

```ruby
%h1= @blog.title
%p=  @blog.content

= render partial: 'comments/tree', locals: { comments_tree: @comments, commentable: @blog }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request