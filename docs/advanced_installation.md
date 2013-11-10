&larr; &nbsp; [documentation](documentation.md)

## Advanced Installation

### 1. Gems install

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
  include TheComments::Commentable

  belongs_to :user

  # Denormalization methods
  # Migration: t.string :title
  # => "My new awesome post"
  def commentable_title
    try(:title) || "Undefined post title"
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
    try(:state) || "published"
  end
end
```

### 5. Mount Engine routes

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

### 6. Assets install

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

### 7. Controller code example

**app/controllers/posts_controllers.rb**

```ruby
def show
  @post     = Post.find params[:id]
  @comments = @post.comments.with_state([:draft, :published])
end
```

### 8. View code example

**app/views/posts/show.html.haml**

```haml
= render partial: 'the_comments/tree', locals: { commentable: @post, comments_tree: @comments }
```
