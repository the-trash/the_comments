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
:warning: &nbsp;  **OPEN EACH OF CREATED MIGRATION FILES AND FOLLOW AN INSTRUCTIONS**
<hr>


**Invoke migrations**

```
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
= render partial: 'the_comments/haml/tree', locals: { commentable: @post, comments_tree: @comments }
```
