&larr; &nbsp; [documentation](documentation.md)

### What is ComComs?

:warning: &nbsp; **comcoms** - is main method to get all comments related with user's commentable models.

:warning: &nbsp; **comments** - is main method to get comments related with any commentable model.

**ComComs** - **com**ments of **com**mentable models

ComComs are all incoming comments for all models, where this user is owner.

For example, some user **has_many :posts**, and  **has_many :products** - all comments for all user's posts and all user's products called as **comcoms**.

#### Why we need ComComs?

User model can be commentable too. For example to build user's "public wall" (like tweets list for current user).

And we should to separate **comments** attached to user model (tweets) and comments attached to any another user's model.

That is why User model in-fact has following relationship declarations:

```ruby
class User < ActiveRecord::Base
  has_many :comcoms, class_name: :Comment, foreign_key: :holder_id
  
  # and if User model is commentable model
  # has_many :comments, as: :commentable
  
  has_many :posts
  has_many :products
end
```

in real application it should be described like this:

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser
  include TheCommentsCommentable
  
  has_many :posts
  has_many :products
end
```

But in most popular situation User model should not be commentable, and you should use only **comcoms** method to get all comments related with this user:

```ruby
class User < ActiveRecord::Base
  include TheCommentsUser

  has_many :posts
  has_many :products
end
```

and later in your application

```ruby
@user = User.find params[:id]
@user.comcoms.count # => 42
```
