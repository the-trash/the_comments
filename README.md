# TheComments 0.0.9

TheComments - comments tree for your web project.

### Main features

* **Comments tree** (via [TheSortableTree](https://github.com/the-teacher/the_sortable_tree) custom helper)
* **No captcha!** Tricks and traps for SpamBots instead Captcha
* **IP** and **User Agent** black lists
* Useful **Cache counters** for Users and Commentable objects
* Designed for external content filters (**sanitize** , **RedCloth**, **Markdown**)
* Open comments with moderation
* Creator of comments can see his comments via **view_token** (_view token_ stored with cookies)

### Requires

```ruby
  gem 'awesome_nested_set'
  gem 'the_sortable_tree'
  gem 'state_machine'
```

### Anti Spam system

User agent must have:

* Cookies support
* JavaScript and Ajax support

Usually spambot not support cookies and JavaScript

Comment form have:

* fake (hidden) email fields

Usually spam bot puts data in fake inputs

## Installation

```ruby
  gem 'the_comments'

  bundle exec rails g model comment --migration=false

  bundle exec rake the_comments_engine:install:migrations

  class Blog < ActiveRecord::Base
    has_many :comments, as: :commentable
  end

  class Comment < ActiveRecord::Base
    include TheCommentModel
  end

```

Add this line to your application's Gemfile:

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install the_comments

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
