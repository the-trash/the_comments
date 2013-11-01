### Advanced Installation

**Gemfile**

```ruby
# TheComments base
gem 'the_comments', "~> 2.0"

gem 'haml'                # or gem 'slim'
gem 'awesome_nested_set'  # or same gem

# TheComments Admin UI gems

# pagination
gem 'kaminari'

# bootstrap 3
gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass'
```

**Bundle**

```
bundle
```

**app/assets/stylesheets/admin_panel.css**

```css
/*
*= require bootstrap
*/
```

**app/assets/javascripts/admin_panel.js**

```js
//= require jquery
//= require jquery_ujs

//= require bootstrap
//= require the_comments_manage
```

**Admin Layout**

```haml
!!! 5
%html(lang="en")
  %head
    %meta(charset="utf-8")
    %meta(http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1")
    %meta(name="viewport" content="width=device-width, initial-scale=1.0")
    %title= content_for?(:title) ? yield(:title) : "Admin Panel"
    %link(href="favicon.ico" rel="shortcut icon")

    = stylesheet_link_tag    :admin_panel
    = javascript_include_tag :admin_panel
    = csrf_meta_tags

  %body
    .container
      .row
        .col-md-12
          %h3= content_for?(:title) ? yield(:title) : "Admin Panel"
      .row
        .col-md-3
          = yield :comments_sidebar
        .col-md-9
          = yield :comments_main

    = stylesheet_link_tag "//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css"
```

**localhost:3000/comments/manage**
