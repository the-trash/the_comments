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
bundle exec rails g model comment               --migration=false
bundle exec rails g model ip_black_list         --migration=false
bundle exec rails g model user_agent_black_list --migration=false

bundle exec rake the_comments_engine:install:migrations
```

**bundle exec rake db:migrate**

### User Model

```ruby
class User < ActiveRecord::Base
  # your implementation of role policy
  def admin?
    self == User.first
  end

  # include Model methods
  include TheCommentModels::User
  
  # denormalization for commentable objects
  def commentable_title
    login
  end

  def commentable_path
    [class.to_s.tableize, login].join('/')
  end

  # Comments moderator checking (simple example)
  # Usually comment's holder should be moderator
  def comment_moderator? comment
    admin? || id == comment.holder_id
  end

end
```

**User#coments** - comments. Set of created comments

```ruby
User.first.comments
# => Array of comments, where User is creator (owner)
```

**User#comcoms** - commentable comments. Set of all comments of all owned commentable objects of this user.

```ruby
User.first.comcoms
# => Array of all comments of all owned commentable objects, where User is holder
# Holder should be moderator of this comments
# because this user should maintain cleaness his commentable objects
```

**Attention!** You should be sure that you understand who is owner, and who is holder of comments!

### Commentable Model (Page, Blog, Article, User ...)

**Attention!** User model can be commentable object too. 

```ruby
class Blog < ActiveRecord::Base
  has_many :comments, as: :commentable

  # denormalization for commentable objects
  def commentable_title
    title
  end

  # denormalization for commentable objects
  def commentable_path
    [self.class.to_s.tableize, slug_id].join('/')
  end
end
```

### Comment Model

```ruby
class Comment < ActiveRecord::Base
  include TheCommentModels::Comment

  # Define comment avatar
  # Usually we use Comment#user (owner of comment) to define avatar
  # @blog.comments.includes(:user) <= use includes(:user) to decrease queries count
  # comment#user.avarat_url

  # but you can use different way
  def avatar_url
    hash = Digest::MD5.hexdigest self.id.to_s
    "http://www.gravatar.com/avatar/#{hash}?s=30&d=identicon"
  end

  # Define your filters for content
  # Expample for: gem 'RedCloth', gem 'sanitize'
  # your personal SmilesProcessor
  def prepare_content
    text = self.raw_content
    text = RedCloth.new(text).to_html
    text = SmilesProcessor.new(text)
    text = Sanitize.clean(text, Sanitize::Config::RELAXED)
    self.content = text
  end
end
```

### IP, User Agent black list

Models should looks like this:

```ruby
class IpBlackList < ActiveRecord::Base
  include TheCommentModels::BlackIp
end

class UserAgentBlackList < ActiveRecord::Base
  include TheCommentModels::BlackUserAgent
end
```


### Commentable controller

```ruby
class BlogsController < ApplicationController
  include TheCommentsController::Cookies
  include TheCommentsController::ViewToken

  def show
    @blog     = Blog.where(id: params[:id]).with_states(:published).first
    @comments = @blog.comments.with_state([:draft, :published]).nested_set
  end
end
```

### View

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