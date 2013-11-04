&larr; &nbsp; [documentation](documentation.md)

### Comment API

```ruby
@comment = Comment.last

# Comment creator, can be nil (for Guest)
@comment.user # => User

# Comment holder
# Owner of commentable object
# shouldn't be nil, should be defined on create
@comment.holder  # => User

# Commentable object
@comment.commentable # => Post

# Raw user input
@comment.raw_content

# Processed user input
# method *prepare_content* should be redefined by developer
@comment.content

# Denormalization fields
@comment.commentable_title  # => "Harum sint error odit."
@comment.commentable_url    # => "/posts/7"
@comment.commentable_state  # => "published"

# Stat info from request
# Can be used for spam detection
@comment.user_agent       # => Opera/9.80 (Windows NT 5.1; U; en) Presto/2.2.15 Version/10.10 
@comment.tolerance_time   # => 5 (secs)
@comment.referer          # => localhost:3000/post/7
@comment.ip               # => 192.168.0.12

# State
@comment.state # => draft | published | deleted

# Spam flag
@comment.spam # => true

# Alias for *mark_as_spam*
@comment.to_spam

# mark this comment and all descendants as spam/not spam
@comment.mark_as_spam
@comment.mark_as_not_spam

# Comment's creator avatar
# this method can be redefined by developer
@comment.avatar_url # => "https://2.gravatar.com/avatar/015e ... 2f05?s=42&d=https://identicons.github.com/AVATAR.png" 

# Anchor of comment
# this method can be redefined by developer
@comment.anchor # => b58020
```