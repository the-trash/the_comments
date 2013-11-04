&larr; &nbsp; [documentation](documentation.md)

### User API

**When User is not commentable model**

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser

  has_many :posts     # commentable model
  has_many :products  # commentable model
end
```

:warning: &nbsp; Please, read this: [What is ComComs?](what_is_comcoms.md)


We can use following methods

```ruby
@user = User.first

@user.comcoms #=> all comments for posts and products, where user is owner

# cache counters
@user.draft_comcoms_count     # => 1
@user.published_comcoms_count # => 5
@user.deleted_comcoms_count   # => 3
@user.spam_comcoms_count      # => 2

# equal values, but with request to database
@user.comcoms.with_state([:draft]).count      # => 1
@user.comcoms.with_state([:published]).count  # => 5
@user.comcoms.with_state([:deleted]).count    # => 3
@user.comcoms.where(spam: true).count         # => 2

# draft and published comments
# written by this user
@user.my_comments  # => ActiveRecord::Relation

# cache counters for comments
# written by this user
# there is no cache counter for deleted state!
@user.my_draft_comments_count         # => 3
@user.my_published_comments_count     # => 7

# equal values, but with request to database
@user.my_draft_comments.count       # => 3
@user.my_published_comments.count   # => 7
@user.my_deleted_comments.count     # => 1

# helper methods to get comments
# written by this user
@user.my_draft_comments      # => ActiveRecord::Relation
@user.my_published_comments  # => ActiveRecord::Relation
@user.my_deleted_comments    # => ActiveRecord::Relation

# recalculate cache counters
@user.recalculate_my_comments_counter!
```

**When User is commentable model**

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser
  include TheCommentsCommentable

  has_many :posts     # commentable model
  has_many :products  # commentable model
end
```

you should to use following instruction [Commentable API](commentable_api.md)
