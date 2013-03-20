# TheComments 0.9.0

TheComments - probably, best solution for comments for Ruby on Rails.

### Intro

* [What's wrong with other gems?](#whats-wrong-with-other-gems)
* [Concepts & Denormalization](#concepts--denormalization)
* [Anti Spam system](#anti-spam-system)

This gem has many steps to install. You should be strong and be careful to setup it.

Just follow an installation instruction step by step, and I sure - everything will be fine!

**Installation process consist of 4 main steps:**

* [Gem Installation](#gem-installation)
* [Code Installation](#code-installation)
* [Tuning](#tuning)
* [Using](#using)

### My hopes about comments system

* Open comments for everybody (by default). *I hate user registration*
* Polymorphic comments for any AR Model
* Threading for comments (can be plain comments list)
* Comment counters for commentable objects and User
* Moderation for comments and simple Admin UI
* Spam traps instead Captcha. *I hate Captcha*
* Blacklists for IP and UserAgent
* Denormalization for fast and Request-free comment list building
* Ready for external content filters (<b>sanitize</b>, <b>RedCloth</b>, <b>Markdown</b>)
* Highlighting and Jumping to comment via anchor
* Ready for Rails4 (and Rails::Engine)
* Delete without destroy

## Gem Installation

**1)** change your Gemfile

```ruby
# I use *awesome_nested_set* gem to provide threading for comments
# But you can use other nested set gem, for example:
# gem 'nested_set' (github.com/skyeagle/nested_set)
gem 'awesome_nested_set'

# I use haml for default views
# You can remove this dependancy,
# but you will should rewrite default views with your template engine
gem 'haml'

# finally, this gem
gem 'the_comments'
```

**2)** bundle

**3)** Copy migration file into application, <b style="color:red">open file and follow instruction</b> in it

```ruby
bundle exec rake the_comments_engine:install:migrations
```

**4)** run migration

```ruby
bundle exec rake db:migrate
```

## Code Installation

**1)** Run generator, open created files and follow instructions in files.

```ruby
bundle exec rails g the_comments install
```

*List of created files:*

```ruby
config/initializers/the_comments.rb

app/controllers/comments_controller.rb
app/controllers/ip_black_lists_controller.rb
app/controllers/user_agent_black_lists_controller.rb
```

**2)** Change your ApplicationController

```ruby
class ApplicationController < ActionController::Base
  include TheCommentsController::ViewToken
end
```

**3)** Assets

*app/assets/javascripts/application.js*

```js
//= require the_comments
//= require the_comments_manage
```

*app/assets/stylesheets/application.css*

```css
/*
 *= require the_comments
*/
```

**4)** Copy view files into your application

```ruby
bundle exec rails g the_comments:views views
```

*List of created directories with view files:*

```ruby
app/views/the_comments/*.haml
app/views/ip_black_lists/*.haml
app/views/user_agent_black_lists/*.haml
```

## Tuning

### User Model

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser

  # Your implementation of role policy
  def admin?
    self == User.first
  end

  # Comments moderator checking (simple example)
  # Usually comment's holder should be moderator
  def comment_moderator? comment
    admin? || id == comment.holder_id
  end
end
```

### Any Commentable Model (Page, Blog, Article, User ...)

```ruby
class Blog < ActiveRecord::Base
  include TheCommentsCommentable

  def commentable_title
    # by default:  try(:title) || 'Undefined title'
    # for example: "My first blog post"
    blog_post_name
  end

  def commentable_url
    # by default:  ['', self.class.to_s.tableize, self.to_param].join('/')
    # for example: "blogs/1-my-first-blog-post"
    [self.class.to_s.tableize, slug_id].join('/')
  end

  def commentable_state
    # by default:  try(:state)
    # for example: "draft"
    self.ban_flag == true ? :banned : :published
  end
end
```

### Comment Model

```ruby
class Comment < ActiveRecord::Base
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

## Using

### Commentable controller

```ruby
class BlogsController < ApplicationController
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

## Concepts & Denormalization

Primarily we should to understand 2 important concept:

#### Comments

**User#posted_comments** (has_many)

Set of comments, where current user is owner ( *Comment#user_id == current_user.id*).

**User#comments** (has_many)

User Model can be commentable object too.

Set of comments, where current user is commentable object.

#### Comcoms (COMments of COMmentable objects)

**User#comcoms** (has_many)

Set of all comments belongs to commentable objects of current_user ( *Blog#user_id == current_user.id* => Blog#has_many(:comments) => *Comment#holder_id == current_user.id*). *Comment#holder_id* should not be empty, because we should to know, who is moderator of this comment.

In fact moderator is user which have a non empty set of comcoms. This user should moderate his set of comcoms. Comment#holder_id define 

#### Denormalization

Now we need to look at denormalization of commentable object into Comment.

Every comments can have 3 important fields with data from commentable object.

If you need to build common list of comments for different Commentable Models, to reduce requests we need following fields:

* **Comment#commentable_title** - for example: "My first post about Ruby On Rails"
* **Comment#commentable_url** - for example: "/posts/1-my-first-post-about-ruby-on-rails"
* **Comment#commentable_state** - for example: "draft"

In common list of comments we should not have comments with { *draft*, *blocked*, *deleted* } (etc) for comemntable objects.

With denormalization we can do some code like this:

```ruby
@comments = Comment.with_state(:published)
                   .where(commentable_state: [:published])
                   .order('created_at DESC')
                   .page(params[:page])
```

And now! (Ta-Da!)

```ruby
- @comments.each do |comment|
  %div
    %p= comment.commentable_title
    %p= link_to comment.commentable_title, comment.commentable_url
    %p= comment.content
```

That is why any **commentable Model should have few methods** to provide denormalization for Comments.

### Anti Spam system

**1) Moderation**

**2) User agent must have:**

* Cookies support
* JavaScript and Ajax support

_Usually spambots not support Cookies and JavaScript_

**3) Comment form mast have:**

* fake (hidden via css) fields

_Usually spambots puts data in fake inputs_

**4) Trap via time:**

* User should be few seconds on page, before comment sending (by default 5 sec)

_Usually spambots works faster, than human. We can try to use this feature of behavior_

**5) IP and User Agent blacklists**

### What's wrong with other gems?

Just look at [Ruby-Toolbox](https://www.ruby-toolbox.com/categories/rails_comments). What we can see?

* [Acts as commentable with threading](https://github.com/elight/acts_as_commentable_with_threading) - so, guys, where is the render helper for the tree? There is no helper! Should  I make render helper for tree by myself? Nooooo!!! I'm so sorry, but I can't use this gem. 
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) - so, I can see code for models. But I can't see code for controllers and views. Unfortunately, there is no threading. It's not enough for me.
* [opinio](https://github.com/Draiken/opinio) - looks better, but there is no threading. I want to have more!
* [has_threaded_comments](https://github.com/aarongough/has_threaded_comments) - Nice work! Nice gem! Models, controllers, views, view helper for tree rendering! **But**, last activity 2 years ago, I need few features, I think - I can make it better.

![TheComments](https://raw.github.com/open-cook/the_comments/master/the_comments.jpg)

### Strong dependencies of gem

```ruby
gem 'the_sortable_tree'
gem 'state_machine'
```

* **the_sortable_tree** - render helper for nested set
* **state_machine** - states for moderation and callbacks for recalculating of counters when state of comment was changed

### User methods

User's posted comments 

* @user.<b>posted_comments</b>

User comments methods

* @user.<b>coments</b>
* @user.<b>comments_sum</b>
* @user.<b>draft_comments_count</b>
* @user.<b>published_comments_count</b>
* @user.<b>deleted_comments_count</b>

User comcoms methods

* @user.<b>comcoms</b>
* @user.<b>comcoms_sum</b>
* @user.<b>draft_comcoms_count</b>
* @user.<b>published_comcoms_count</b>
* @user.<b>deleted_comcoms_count</b>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request