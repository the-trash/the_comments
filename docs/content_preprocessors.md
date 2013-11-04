&larr; &nbsp; [documentation](documentation.md)

### Text preprocessors

TheComments designed for using with text preprocessors: Textile, Markdown, Sanitize, Coderay etc.

That is why Comment model has 2 fields for user input: **raw_content** and **content**

```ruby
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    # ...
    
    t.text :raw_content
    t.text :content
      
    # ...
    end
  end
end
```

**raw_content** - field with original user's input

**content** - field with processed user's input

<hr>

**before_save :prepare_content** - provides processing of raw user's input

By default **prepare_content** looks like this:

```ruby
  def prepare_content
    self.content = self.raw_content
  end
```

I think every developer should redefine this behaviour. To do this you should to use following instructions.

### Comment Model customization

invoke TheComments generator

```ruby
bundle exec rails g the_comments models
```

This will create **app/models/comment.rb**

```ruby
class Comment < ActiveRecord::Base
  include TheCommentsBase

  # ---------------------------------------------------
  # Define your filters for content
  # Expample for: gem 'RedCloth', gem 'sanitize'
  # your personal SmilesProcessor

  # def prepare_content
  # text = self.raw_content
  # text = RedCloth.new(text).to_html
  # text = SmilesProcessor.new(text)
  # text = Sanitize.clean(text, Sanitize::Config::RELAXED)
  # self.content = text
  # end
  # ---------------------------------------------------
end
```

Just redefine **prepare_content** for your purposes

