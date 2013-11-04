&larr; &nbsp; [documentation](documentation.md)

### TheComments config

Following rails generator will copy default config file into your application

```ruby
bundle exec rails g the_comments config
```

**config/initializers/the_comments.rb**

```ruby
# TheComments.config.param_name => value

TheComments.configure do |config|
  config.max_reply_depth     = 3                 # comments tree depth
  config.tolerance_time      = 5                 # sec - after this delay user can post a comment
  config.default_state       = :draft            # default state for comment
  config.default_owner_state = :published        # default state for comment for Moderator
  config.empty_inputs        = [:commentBody]    # array of spam trap fields
  config.default_title       = 'Undefined title' # default commentable_title for denormalization

  config.empty_trap_protection     = true
  config.tolerance_time_protection = true
end
```
