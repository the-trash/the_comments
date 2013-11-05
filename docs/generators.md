&larr; &nbsp; [documentation](documentation.md)

## Generators

```ruby
rails g the_comments NAME
rails g the_comments:views NAME
```

#### Migrations

```ruby
rake the_comments_engine:install:migrations
```

### Full list

```ruby
rails g the_comments --help
```

#### Main

```ruby
rails g the_comments install
```

This will create:

* config/initializers/the_comments.rb
* app/controllers/comments_controller.rb
* app/models/comment.rb

#### Controllers

```ruby
rails g the_comments controllers
```

This will create:

* app/controllers/comments_controller.rb

#### Models

```ruby
rails g the_comments models
```

This will create:

* app/models/comment.rb

#### Config

```ruby
rails g the_comments config
```

#### Locals

```ruby
rails g the_comments locales
```

#### Views

```ruby
rails g the_comments:views js
rails g the_comments:views css
rails g the_comments:views assets
rails g the_comments:views helper
rails g the_comments:views views
```
