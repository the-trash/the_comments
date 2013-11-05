&larr; &nbsp; [documentation](documentation.md)

### What's wrong with other gems?

Just look at [Ruby-Toolbox](https://www.ruby-toolbox.com/categories/rails_comments). What we can see?

* [Acts as commentable with threading](https://github.com/elight/acts_as_commentable_with_threading) - so, guys, where is the render helper for the tree? There is no helper! Should  I make render helper for tree by myself? Nooooo!!! I'm so sorry, but I can't use this gem. 
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) - so, I can see code for models. But I can't see code for controllers and views. Unfortunately, there is no threading. It's not enough for me.
* [opinio](https://github.com/Draiken/opinio) - looks better, but there is no threading. I want to have more!
* [has_threaded_comments](https://github.com/aarongough/has_threaded_comments) - Nice work! Nice gem! Models, controllers, views, view helper for tree rendering! **But**, last activity 2 years ago, I need few features, I think - I can make it better.

### Why TheComments is better than others gems?

1. **Only TheComments has special helper for tree rendering** (based on [TheSortableTree](https://github.com/the-teacher/the_sortable_tree)).
2. TheComments designed to reduce requests to database. I say about useful cache counters.
3. TheComments has solution for [building of Recent Comments](https://github.com/the-teacher/the_comments/blob/master/docs/denormalization_and_recent_comments.md) (for polymorphic relations)
4. TheComments designed for text preprocessors (Textile, Markdown, Sanitize, Coderay etc.)
5. TheComments has admin UI based on bootstrap 3
6. TheComments is "all-in-one" solutions.<br>
   It has: Models and Controllers logic (via concerns), Generators, Views, Helper for fast Tree rendering and Admin UI.
   
