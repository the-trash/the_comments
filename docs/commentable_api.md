### Commentable API

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

# Alias for:
# draft_comments_count + published_comments_count
@post.comments_sum # => 3

# recalculate cache counters
@post.recalculate_comments_counters!

# Default Denormalization methods
# should be redefined by developer
@post.commentable_title   => "Maiores eos rerum numquam aut."
@post.commentable_url     => "/posts/9"
@post.commentable_state   => "published"
```