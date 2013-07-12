# TheComments 1.0.0

TheComments - just comment system for my Ruby on Rails 4 projects. [(rubygems)](http://rubygems.org/gems/the_comments)

## Keywords

Comments for Rails 4, Comments with threading, Nested Comments, Polymorphic comments, Acts as commentable, Comment functionality, Comments, Threading, Rails 4, Comments with moderation, I hate captcha!

## Screenshots

**click to zoom**

<table>
  <tr>
    <td width="20%">Guest view</td>
    <td width="20%">Admin view</td>
    <td width="20%">Edit</td>
    <td width="20%">Cache counters & User Cabinet</td>
    <td width="20%">Recent comments & Denormalization</td>
  </tr>
  <tr>
    <td width="20%"><img width="100%" height="100%" src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_2.gif" alt="the_comments"></td>
    <td width="20%"><img width="100%" height="100%" src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_1.gif" alt="the_comments"></td>
    <td width="20%"><img width="100%" height="100%" src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_4.gif" alt="the_comments"></td>    
    <td width="20%"><img width="100%" height="100%" src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_3.gif" alt="the_comments"></td>    
    <td width="20%"><img width="100%" height="100%" src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_5.gif" alt="the_comments"></td>
  </tr>
</table>

### Main features

* Threaded comments
* Tree rendering via [TheSortableTree](https://github.com/the-teacher/the_sortable_tree)
* [Denormalization](#denormalization) for Recent comments
* Usefull cache counters
* Basic AntiSpam system
* Online Support via skype: **ilya.killich**

### Intro (understanding)

* [My hopes about comments system](#my-hopes-about-comments-system)
* [What's wrong with other gems?](#whats-wrong-with-other-gems)
* [Comments, Posted comments & ComComs](#comments-posted-comments-comcoms)
* [Denormalization and Recent comments](#denormalization)
* [Recent comments building](#recent-comments-building)
* [AntiSpam system](#antispam-system)
* [Customization](#customization)
* [User methods](#user-methods)
* [Commentable methods](#commentable-methods)
* [Online Support](#online-support)
* [About author](#about-author)
* [What about specs?](#what-about-specs)


## Installation

This gem has many steps to install. Be careful when installing and keep calm.

Just follow an installation instruction step by step and everything will be fine!

**Installation process consist of 4 main steps:**

* [Gem Installation](#gem-installation)
* [Code Installation](#code-installation)
* [Tuning](#tuning)
* [Using](#using)

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

**3)** Create migration file with following generator.

```ruby
bundle exec rake the_comments_engine:install:migrations
```

<b>OPEN MIGRATION FILE AND FOLLOW AN INSTRUCTION</b>.

**4)** run migration

```ruby
bundle exec rake db:migrate
```

## Code Installation

**1)** Assets

*app/assets/javascripts/application.js*

```js
//= require the_comments
//= require the_comments_manage
```

*app/assets/stylesheets/application.css*

```css
*= require the_comments
```

**2)** Change your ApplicationController

```ruby
class ApplicationController < ActionController::Base
  include TheCommentsController::ViewToken
end
```

**3)** Run generator

```ruby
bundle exec rails g the_comments install
```

<b>OPEN EACH OF CREATED FILES AND FOLLOW INSTRUCTIONS</b>.

*List of created files:*

```ruby
config/initializers/the_comments.rb

app/models/ip_black_list.rb
app/models/user_agent_black_list.rb

app/controllers/comments_controller.rb
app/controllers/ip_black_lists_controller.rb
app/controllers/user_agent_black_lists_controller.rb
```

**4)** Run view generator for coping view files into your App

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

### Any Commentable Model (Page, Blog, Article, User(!) ...)

Read more about **commentable_title**, **commentable_url** and **commentable_state** methods here: [Denormalization and Recent comments](#denormalization)

```ruby
class Blog < ActiveRecord::Base
  include TheCommentsCommentable

  def commentable_title
    # by default: try(:title) || TheComments.config.default_title
    # for example: "My first blog post"
    blog_post_name
  end

  def commentable_url
    # by default:  ['', self.class.to_s.tableize, self.to_param].join('/')
    # for example: "/blogs/1-my-first-blog-post"
    ['', self.class.to_s.tableize, slug_id].join('/')
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

= render partial: 'the_comments/tree', locals: { commentable: @blog, comments_tree: @comments }
```

## Understanding

### My hopes about comments system

* Open comments for everybody (by default). *I hate user registration*
* Polymorphic comments for any AR Model
* Threading for comments (can be plain comments list)
* Cache counters for commentable objects and User
* Moderation for comments and simple Admin UI
* Spam traps instead Captcha. *I hate Captcha*
* Blacklists for IP and UserAgent
* Denormalization for fast and Request-free Recent comments building
* Ready for external content filters (<b>sanitize</b>, <b>RedCloth</b>, <b>Markdown</b>, etc)
* Highlighting and Jumping to comment via anchor
* Ready for Rails4 (and Rails::Engine)
* Ready for JQuery 1.9+
* Delete without destroy

### What's wrong with other gems?

Just look at [Ruby-Toolbox](https://www.ruby-toolbox.com/categories/rails_comments). What we can see?

* [Acts as commentable with threading](https://github.com/elight/acts_as_commentable_with_threading) - so, guys, where is the render helper for the tree? There is no helper! Should  I make render helper for tree by myself? Nooooo!!! I'm so sorry, but I can't use this gem. 
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) - so, I can see code for models. But I can't see code for controllers and views. Unfortunately, there is no threading. It's not enough for me.
* [opinio](https://github.com/Draiken/opinio) - looks better, but there is no threading. I want to have more!
* [has_threaded_comments](https://github.com/aarongough/has_threaded_comments) - Nice work! Nice gem! Models, controllers, views, view helper for tree rendering! **But**, last activity 2 years ago, I need few features, I think - I can make it better.

![TheComments](https://raw.github.com/the-teacher/the_comments/master/docs/the_comments.jpg)

## Comments, Posted comments, ComComs

### Posted comments

**@user.posted_comments** (has_many)

Set of comments, where current user is owner (creator).

```ruby
@my_comments = @user.posted_comments # => [comment, comment, ...]

@comment =  @my_comments.first
@user.id == @comment.user_id # => true
```

### Comments

**@commentable.comments** (has_many)

Set of comments for this commentable object

```ruby
@comments = @blog.comments # => [comment, comment, ...]

@comment = @comments.first
@comment.commentable_id   == @blog.id # => true
@comment.commentable_type == 'Blog'   # => true
```

<b>(!) Attention:</b>  User Model can be commentable object too!

```ruby
@comments = @user.comments # => [comment, comment, ...]

@comment = @comments.first
@comment.commentable_id   == @user.id  # => true
@comment.commentable_type == 'User'    # => true
```

### ComComs (COMments of COMmentable objects)

**@user.comcoms**  (has_many)

Set of All <b>COM</b>ments of All <b>COM</b>mentable objects of this User

```ruby
@comcoms = @user.comcoms # => [comment, comment, ...]

@comcom  =  @comcoms.first
@user.id == @comcom.holder_id  # => true
```

**Comment#holder_id** should not be empty. Because we should to know, who is moderator of this comment.

```ruby
@user.id == @comment.holder_id # => true
# => This user should be MODERATOR for this comment
```

## Denormalization

For building of Recent comments list (for polymorphic relationship) we need to have many additional requests to database. It's classic problem of polymorphic comments.

I use denormalization of commentable objects to solve this problem.

My practice shows - We need 3 denormalized fields into comment for (request-free) building of recent comments list:

<img src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_5.gif" alt="the_comments">

* **Comment#commentable_title** - for example: "My first post about Ruby On Rails"
* **Comment#commentable_url** - for example: "/posts/1-my-first-post-about-ruby-on-rails"
* **Comment#commentable_state** - for example: "draft"

That is why any **Commentable Model should have few methods** to provide denormalization for Comments.

## Recent comments building

Denormalization makes building of Recent comments (for polymorphic relationship) very easy!

Controller:

```ruby
@comments = Comment.with_state(:published)
                   .where(commentable_state: [:published])
                   .order('created_at DESC')
                   .page(params[:page])
```

View:

```ruby
- @comments.each do |comment|
  %div
    %p= comment.commentable_title
    %p= link_to comment.commentable_title, comment.commentable_url
    %p= comment.content
```

### AntiSpam system

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


### Strong dependencies of gem

```ruby
gem 'the_sortable_tree'
gem 'state_machine'
```

* **the_sortable_tree** - render helper for nested set
* **state_machine** - states for moderation and callbacks for recalculating of counters when state of comment was changed

## Customization

You can use **generators** for copy files into your Application. After that you can customize almost everything

Generators list:

```ruby
bundle exec rails g the_comments --help
```

Copy View files for customization:

```ruby
bundle exec rails g the_comments:views assets
bundle exec rails g the_comments:views views
```

Copy Helper file for tree customization:

For more info read [TheSortableTree doc](https://github.com/the-teacher/the_sortable_tree)

```ruby
bundle exec rails g the_comments:views helper
```
### User methods

* @user.<b>posted_comments</b> (all states)
* @user.<b>my_comments</b> (draft, published)
* @user.<b>my_comments_count</b>

Cache counters methods

* @user.<b>recalculate_my_comments_counter!</b>
* @user.<b>recalculate_comcoms_counters!</b>

Comments methods

* @user.<b>comments</b>
* @user.<b>comments_sum</b>
* @user.<b>draft_comments_count</b>
* @user.<b>published_comments_count</b>
* @user.<b>deleted_comments_count</b>

Comcoms methods

* @user.<b>comcoms</b>
* @user.<b>comcoms_sum</b>
* @user.<b>draft_comcoms_count</b>
* @user.<b>published_comcoms_count</b>
* @user.<b>deleted_comcoms_count</b>

### Commentable methods

* @post.<b>comments</b>
* @post.<b>draft_comments_count</b>
* @post.<b>published_comments_count</b>
* @post.<b>deleted_comments_count</b>
* @post.<b>comments_sum</b> (draft + published)
* @post.<b>recalculate_comments_counters!</b>

Denornalization methods

* @post.<b>commentable_title</b>
* @post.<b>commentable_url</b>
* @post.<b>commentable_state</b>

## Online Support

I need your opinion, ideas, user experience - that is why you can ask me about this gem via skype: **ilya.killich**

## About author

Yes, It's true - I was a school teacher in the past.
That's why my login is the-teacher.
Now I'm ruby/frontend developer and [food-blogger](http://open-cook.ru).
I learn, I teach, I make a code. And sorry for my English.

## What about specs?

This gem - just first prototype of my ideas about comment system.
Unfortunatly, I have no time to write many tests for this gem.
Release 1.0.0 works for my pet projects - it's enough for me.
If you have a problem with gem and you can to create coverage tests for this problem - I will be happy to get your pull request.

### Where I can find example of application with the_comments?

This gem is part of new version of my food-blog about modern russian home cuisine. There is code of my tasty CMS [open-cook](https://github.com/open-cook/open-cook)

## Contributing

1. Fork it
2. Clone it into local folder
3. Add to Gemfile via **gem 'the_comments', path: '/path/to/gem/the_comments'**
4. Change code
5. git push origin master
6. Create pull request via github

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
