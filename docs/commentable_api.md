&larr; &nbsp; [documentation](documentation.md)

### Commentable API

```ruby
class Post < ActiveRecord::Base
  include TheCommentsCommentable

  belongs_to :user

  def commentable_title
    try(:title) || "Undefined title" 
  end

  def commentable_url
    ['', self.class.to_s.tableize, id].join('/')
  end

  def commentable_state
    try(:state) || "published"
  end
end
```

```ruby
@post = Post.last

# Post owner
@post.user # => User

# All comments for commentable object
@post.comments # => ActiveRecord:Collection

# Cache counters
@post.draft_comments_count      # => 1
@post.published_comments_count  # => 2
@post.deleted_comments_count    # => 0

# equal values with direct request to database
@post.comments.with_state([:draft]).count      # => 1
@post.comments.with_state([:published]).count  # => 2
@post.comments.with_state([:deleted]).count    # => 0

# Alias for:
# draft_comments_count + published_comments_count
@post.comments_sum # => 3

# Spam comments
@post.comments.where(spam: true) # => ActiveRecord::Relation

# recalculate cache counters
@post.recalculate_comments_counters!

# Default Denormalization methods
# should be redefined by developer
@post.commentable_title   => "Maiores eos rerum numquam aut."
@post.commentable_url     => "/posts/9"
@post.commentable_state   => "published"
```