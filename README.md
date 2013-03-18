# TheComments 0.9.0

TheComments - probably, best solution for comments for Ruby on Rails.

### What's wrong with other gems?

Just look at [Ruby-Toolbox](https://www.ruby-toolbox.com/categories/rails_comments). What we can see?

* [Acts as commentable with threading](https://github.com/elight/acts_as_commentable_with_threading) - so, guys, where is the render helper for the tree? There is no helper! Should  I make render helper for tree by myself? Nooooo!!! I'm so sorry, but I can't use this gem. 
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) - so, I can see code for models. But I can't see code for controllers and views. Unfortunately, there is no threading. It's not enough for me.
* [opinio](https://github.com/Draiken/opinio) - looks better, but there is no threading. I want to have more!
* [has_threaded_comments](https://github.com/aarongough/has_threaded_comments) - Nice work! Nice gem! Models, controllers, views, view helper for tree rendering! **But**, last activity 2 years ago, I need few features, I think - I can make it better.

### In sum

![TheComments](https://raw.github.com/open-cook/the_comments/master/the_comments.jpg)

### My hopes about comments system

* Open comments for everybody (by default). *I hate user registration*
* Moderation for comments and simple Admin UI
* Spam traps instead Captcha. *I hate Captcha*
* Blacklists for IP and UserAgent
* Comment counters for commentable objects and User
* Denormalization for fast and Request-free comment list building
* Ready for external content filters ( **sanitize**, **RedCloth**, **Markdown**)
* Ready for Rails4 (and Rails::Engine)
* Highlighting and Jumping to comment via anchor
* Delete without destroy

### Strong dependencies

```ruby
gem 'awesome_nested_set'
gem 'the_sortable_tree'
gem 'state_machine'
```

* **awesome_nested_set** - for comments threading
* **the_sortable_tree** - render helper for nested set
* **state_machine** - callbacks for recalculating of counters when state of comment was changed

### Anti Spam system

** 1) User agent must have:**

* Cookies support
* JavaScript and Ajax support

_Usually spambots not support Cookies and JavaScript_

** 2) Comment form mast have:**

* fake (hidden via css) fields

_Usually spambots puts data in fake inputs_

Trap via time:

* User should be few seconds on page, before comment sending (by default 5 sec)

_Usually spambots works faster, than human. We can try to use this feature of behavior_

** 3) IP and User Agent blacklists**

** 4) Moderation**

## Installation

```ruby
gem 'the_comments'

# I use haml for default views
# You can remove this dependancy,
# but you will should rewrite default views with your template engine
gem 'haml'
```

**bundle**

## Setup

**1)** Just run:

```ruby
bundle exec rails g the_comments install
```

**2)** Open created files and follow instructions in files.

List of created files:

```
 config/initializers/the_comments.rb

 app/controllers/comments_controller.rb
 app/controllers/ip_black_lists_controller.rb
 app/controllers/user_agent_black_lists_controller.rb
```

**3)** Add TheComment's **include** into *ApplicationController*

```ruby
class ApplicationController < ActionController::Base
  include TheCommentsController::ViewToken
end
```

### Assets

**app/assets/javascripts/application.js**

```js
//= require the_comments
```

**app/assets/stylesheets/application.css**

```css
/*
 *= require the_comments
*/
```

### User Model

```ruby
class User < ActiveRecord::Base
  # Your implementation of role policy
  def admin?
    self == User.first
  end

  # include TheComments methods
  include TheCommentsUser
  
  # denormalization for commentable objects
  def commentable_title
    login
  end

  def commentable_url
    [class.to_s.tableize, login].join('/')
  end

  # Comments moderator checking (simple example)
  # Usually comment's holder should be moderator
  def comment_moderator? comment
    admin? || id == comment.holder_id
  end

end
```

**User#coments** - comments. Set of all created comments

```ruby
User.first.comments
# => Array of comments, where User is creator (owner)
```

**User#comcoms** - commentable comments. Set of all comments of all owned commentable objects of this user.

```ruby
User.first.comcoms
# => Array of all comments of all owned commentable objects, where User is holder
# Usually comment's holder should be moderator of this comments
# because this user should maintain cleaness of his commentable objects
```

**Attention!** You should be sure that you understand who is owner, and who is holder of comments!

### Commentable Model (Page, Blog, Article, User ...)

**Attention!** User model can be commentable object also.

```ruby
class Blog < ActiveRecord::Base
  # include TheComments methods
  include TheCommentsCommentable

  # (!) Every commentable Model must have next 2 methods
  # denormalization for commentable objects
  def commentable_title
    # "My first blog post"
    title
  end

  def commentable_url
    # blogs/1-my-first-blog-post
    [self.class.to_s.tableize, slug_id].join('/')
  end
end
```

### Comment Model

```ruby
class Comment < ActiveRecord::Base
  # include TheComments methods
  include TheCommentsBase

  # Define comment's avatar url
  # Usually we use Comment#user (owner of comment) to define avatar
  # @blog.comments.includes(:user) <= use includes(:user) to decrease queries count
  # comment#user.avatar_url

  # Simple way to define avatar url
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

### IP, User Agent black lists

Models must looks like this:

```ruby
class IpBlackList < ActiveRecord::Base
  include TheCommentsBlackUserAgent
end

class UserAgentBlackList < ActiveRecord::Base
  include TheCommentsBlackIp
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

## Configuration

**config/initializers/the_comments.rb**

```ruby
TheComments.configure do |config|
  config.max_reply_depth = 3                                # 3 by default
  config.tolerance_time  = 15                               # 5 (sec) by default
  config.empty_inputs    = [:email, :message, :commentBody] # [:message] by default
end
```

* **max_reply_depth** - comments tree nesting by default
* **tolerance_time** - how many seconds user should spend on page, before comment send
* **empty_inputs** - names of hidden (via css) fields for spam detecting

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request