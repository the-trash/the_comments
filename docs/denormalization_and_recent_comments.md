&larr; &nbsp; [documentation](documentation.md)

## Denormalization

For building of Recent comments list (for polymorphic relationship) we need to have many additional requests to database. It's classic problem of polymorphic comments.

I use denormalization of commentable objects to solve this problem.

My practice shows - We need 3 denormalized fields into comment for (request-free) building of recent comments list:

<img src="https://raw.github.com/the-teacher/the_comments/master/docs/the_comments_view_5.gif" alt="the_comments">

* **Comment#commentable_title** - for example: "My first post about Ruby On Rails"
* **Comment#commentable_url** - for example: "/posts/1-my-first-post-about-ruby-on-rails"
* **Comment#commentable_state** - for example: "draft"

That is why any **Commentable Model should have few methods** to provide denormalization for Comments.

## Recent comments building

Denormalization makes building of Recent comments (for polymorphic relationship) very easy!

Controller:

```ruby
@comments = Comment.with_state(:published)
                   .where(commentable_state: [:published])
                   .order('created_at DESC')
                   .page(params[:page])
```

View:

```ruby
- @comments.each do |comment|
  %div
    %p= comment.commentable_title
    %p= link_to comment.commentable_title, comment.commentable_url
    %p= comment.content
```
