### Advanced Installation

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

**Copy migrations**

```
rake the_comments_engine:install:migrations
```

<hr>
:warning: &nbsp; **Open and change commentable migration**

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
<hr>


**Invoke migrations**

```
rake db:migrate
```

**Config TheComments gem**

```ruby
bundle exec rails g the_comments config
```

open and change **config/initializers/the_comments.rb**

**app/models/user.rb**

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser

  has_many :posts

  # Your way to define privileged users
  def admin?
    self == User.first
  end

  # Required TheComments methods for users restrictions
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

  # Denormalization methods
  # Migration: t.string :title
  # => "My new awesome post"
  def commentable_title
    title
  end

  # => your way to build URL
  # => "/posts/254"
  def commentable_url
    ['', self.class.to_s.tableize, id].join('/')
  end

  # gem 'state_machine'
  # Migration: t.string :state
  # => "published" | "draft" | "deleted"
  def commentable_state
    state
  end
end
```

**app/models/comment.rb**

```
bundle exec rails g the_comments models
```

will create **app/models/comment.rb**

```ruby
class Comment < ActiveRecord::Base
  include TheCommentsBase

  # ---------------------------------------------------
  # Define comment's avatar url
  # Usually we use Comment#user (owner of comment) to define avatar
  # @blog.comments.includes(:user) <= use includes(:user) to decrease queries count
  # comment#user.avatar_url
  # ---------------------------------------------------

  # ---------------------------------------------------
  # Simple way to define avatar url

  # def avatar_url
  #   hash = Digest::MD5.hexdigest self.id.to_s
  #   "http://www.gravatar.com/avatar/#{hash}?s=30&d=identicon"
  # end
  # ---------------------------------------------------

  # ---------------------------------------------------
  # Define your filters for content
  # Expample for: gem 'RedCloth', gem 'sanitize'
  # your personal SmilesProcessor

  # def prepare_content
  #   text = self.raw_content
  #   text = RedCloth.new(text).to_html
  #   text = SmilesProcessor.new(text)
  #   text = Sanitize.clean(text, Sanitize::Config::RELAXED)
  #   self.content = text
  # end
  # ---------------------------------------------------
end
```

**app/controllers/posts_controllers.rb**

```ruby
def show
  @post     = Post.find params[:id]
  @comments = @post.comments.with_state([:draft, :published])
end
```

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

**app/views/posts/show.html.haml**

```haml
= render partial: 'the_comments/tree', locals: { commentable: @post, comments_tree: @comments }
```

(and same code for SLIM)