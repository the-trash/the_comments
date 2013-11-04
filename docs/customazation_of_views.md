&larr; &nbsp; [documentation](documentation.md)

## Customization

You can use **rails generators** for copy files into your Application. After that you can customize almost everything

Generators list:

```ruby
bundle exec rails g the_comments --help
```

### Customization of views

Copy View files for customization:

```ruby
bundle exec rails g the_comments:views assets
bundle exec rails g the_comments:views views
```

### Customization of comments tree

Copy Helper file for tree customization:

```ruby
bundle exec rails g the_comments:views helper
```

For more info read [TheSortableTree doc](https://github.com/the-teacher/the_sortable_tree)
