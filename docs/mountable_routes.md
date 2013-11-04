&larr; &nbsp; [documentation](documentation.md)

## Mountable Routes

Now gem has mountable routes. It's was not my idea, but guys said - it's very helpful. So, ok!

You should mount routes to your app.

:warning: &nbsp; Default views based on **as: :comments** argument. If, you want to change it - you should customize default views.

**config/routes.rb**

```ruby
MyApp::Application.routes.draw do
  root 'posts#index'
  resources :posts

  # ...

  mount TheComments::Engine => '/', as: :comments
end
```

And after that you can see routes:

```ruby
rake routes | grep comments
```

```ruby
 comments        /                         TheComments::Engine
         to_spam_comment POST   /comments/:id/to_spam(.:format)      comments#to_spam
        to_draft_comment POST   /comments/:id/to_draft(.:format)     comments#to_draft
    to_published_comment POST   /comments/:id/to_published(.:format) comments#to_published
      to_deleted_comment DELETE /comments/:id/to_deleted(.:format)   comments#to_deleted
         manage_comments GET    /comments/manage(.:format)           comments#manage
       my_draft_comments GET    /comments/my_draft(.:format)         comments#my_draft
   my_published_comments GET    /comments/my_published(.:format)     comments#my_published
    my_comments_comments GET    /comments/my_comments(.:format)      comments#my_comments
    total_draft_comments GET    /comments/total_draft(.:format)      comments#total_draft
total_published_comments GET    /comments/total_published(.:format)  comments#total_published
  total_deleted_comments GET    /comments/total_deleted(.:format)    comments#total_deleted
     total_spam_comments GET    /comments/total_spam(.:format)       comments#total_spam
          draft_comments GET    /comments/draft(.:format)            comments#draft
      published_comments GET    /comments/published(.:format)        comments#published
        deleted_comments GET    /comments/deleted(.:format)          comments#deleted
           spam_comments GET    /comments/spam(.:format)             comments#spam
                comments GET    /comments(.:format)                  comments#index
                         POST   /comments(.:format)                  comments#create
             new_comment GET    /comments/new(.:format)              comments#new
            edit_comment GET    /comments/:id/edit(.:format)         comments#edit
                 comment GET    /comments/:id(.:format)              comments#show
                         PATCH  /comments/:id(.:format)              comments#update
                         PUT    /comments/:id(.:format)              comments#update
                         DELETE /comments/:id(.:format)              comments#destroy
```

And now you can use url helpers with 2 ways:

### Way 1. Url Helpers

```ruby
= link_to 'link', comments.comments_path
= link_to 'link', comments.manage_comments_path
= link_to 'link', comments.new_comment_path

= link_to 'link', comments.comment_path(@comment)
= link_to 'link', comments.to_spam_comment_path(@comment)
```

### Way 2. Array notation

```ruby
= link_to 'link', [comments, :index]
= link_to 'link', [comments, :manage]
= link_to 'link', [comments, :new]

= link_to 'link', [comments, @comment]
= link_to 'link', [comments, :to_spam, @comment]
```