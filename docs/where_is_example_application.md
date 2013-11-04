&larr; &nbsp; [documentation](documentation.md)

### Dummy Application

Repo of TheComments has dummy application for developmet and testing.

It's here: [Dummy App](https://github.com/the-teacher/the_comments/tree/master/spec/dummy_app)

For run dummy app, your should do that:

```ruby
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle

rake db:bootstrap_and_seed

rails s -p 3000 -b localhost
```

### Run tests

Following instructions should helps to run simple tests:

```ruby
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle

rake db:bootstrap RAILS_ENV=test

rspec --format documentation
```
