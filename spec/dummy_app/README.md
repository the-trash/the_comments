## TheComments Dummy App

### First step

```
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle
```

### App start

```
rake db:bootstrap_and_seed

rails s -p 3000 -b localhost
```

Browser

```
http://localhost:3000/
```

### Tests start

```
rake db:bootstrap RAILS_ENV=test

rspec --format documentation
```

### Only for me (don't read this)

base install commands

```
rails g sorcery:install
rails generate rspec:install

rails g the_comments install
rails g the_comments:views views
rails g model post user_id:integer title:string content:text

rake the_comments_engine:install:migrations (EDIT!)

rake db:bootstrap
```