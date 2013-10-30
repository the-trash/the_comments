# TheComments

[![Gem Version](https://badge.fury.io/rb/the_comments.png)](http://badge.fury.io/rb/the_comments) | [![Build Status](https://travis-ci.org/the-teacher/the_comments.png?branch=master)](https://travis-ci.org/the-teacher/the_comments) | [![Code Climate](https://codeclimate.com/github/the-teacher/the_comments.png)](https://codeclimate.com/github/the-teacher/the_comments) | [(rubygems)](http://rubygems.org/gems/the_comments)

TheComments - probably, best commenting system for Rails

### Main features

* Threaded comments
* Usefull cache counters
* Admin UI for moderation
* Online Support via skype: **ilya.killich**
* [Denormalization](https://github.com/the-teacher/the_comments/wiki/Understanding#denormalization) for Recent comments
* Production-ready commenting system for Rails 4+

## Keywords

Comments for Rails 4, Comments with threading, Nested Comments, Polymorphic comments, Acts as commentable, Comment functionality, Rails 4, Comments with moderation, I hate captcha!

## Documentation

* [Screenshots](https://github.com/the-teacher/the_comments/wiki/Screenshots)
* [Understanding](https://github.com/the-teacher/the_comments/wiki/Understanding)
* [Installation](https://github.com/the-teacher/the_comments/wiki/Installation)
* [User Model API](https://github.com/the-teacher/the_comments/wiki/User-Model-API)
* [Customization](https://github.com/the-teacher/the_comments/wiki/Customization)

## Installation

**Gemfile**

```ruby
gem 'the_comments', "~> 2.0"

gem 'haml'                # or gem 'slim'
gem 'awesome_nested_set'  # or same gem
```

**Bundle**

```
bundle
```

**Copy migrations and run**

```
rake the_comments_engine:install:migrations

rake db:migrate
```

**app/models/user.rb**

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser

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
  include TheCommentsCommentable

  belongs_to :user

  def commentable_title
    title
  end

  def commentable_url
    ['', self.class.to_s.tableize, id].join('/')
  end

  def commentable_state
    :published.to_s
  end
end
```

**app/models/comment.rb**

```ruby
class Comment < ActiveRecord::Base
  include TheCommentsBase
end
```

**app/controllers/posts_controllers.rb**

```ruby
  def show
    @post     = Post.find params[:id]
    @comments = @post.comments.with_state([:draft, :published])
  end
```

**app/views/posts/show.html.haml**

```haml
= render partial: 'the_comments/haml/tree', locals: { commentable: @post, comments_tree: @comments }
```

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
