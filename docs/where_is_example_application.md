&larr; &nbsp; [documentation](documentation.md)

### Dummy Application

TheComments repository contains a dummy application for development and testing.

It's here: [Dummy App](https://github.com/the-teacher/the_comments/tree/master/spec/dummy_app)

To run the dummy app:

```ruby
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle

rake db:bootstrap_and_seed

rails s -p 3000 -b localhost
```

### Run tests

To run the RSPEC tests:

```ruby
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle

rake db:bootstrap RAILS_ENV=test

rspec --format documentation
```
