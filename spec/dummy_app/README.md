### Dummy App 

**Test app for TheComments testing**

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