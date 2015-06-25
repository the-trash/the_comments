&larr; &nbsp; [documentation](documentation.md)

### What's wrong with other gems?

Take a look at [Ruby-Toolbox](https://www.ruby-toolbox.com/categories/rails_comments). What can we see?

* [Acts as commentable with threading](https://github.com/elight/acts_as_commentable_with_threading) - Where is the render helper for the tree? There is no helper! Am I supposed to write a render helper for the tree myself? Nooooo!!! I'm sorry, I can't use this gem. 
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) - I can see the code for models. But I can't see the code for controllers and views. Unfortunately, there is no threading. This isn't enough for me.
* [opinio](https://github.com/Draiken/opinio) - Better, but still no threading. I can do better!
* [has_threaded_comments](https://github.com/aarongough/has_threaded_comments) - A solid gem. Has model, controller and view helpers for tree rendering! **But** last activity was 2 years ago, it still needs a few features - I can do better.

### Why is TheComments better than other gems?

1. TheComments allows for threaded comments
2. **Only TheComments has special helper for tree rendering** (based on [TheSortableTree](https://github.com/the-teacher/the_sortable_tree)).
3. TheComments is designed to reduce database requests. Helpful for cache counters.
4. TheComments has a solution for [building Recent Comments](https://github.com/the-teacher/the_comments/blob/master/docs/denormalization_and_recent_comments.md) (for polymorphic relations)
5. TheComments is designed for text preprocessors (Textile, Markdown, Sanitize, Coderay etc.)
6. TheComments has an admin UI based on bootstrap 3
7. TheComments is an "all-in-one" solution.<br>
   It has: Models and Controllers logic (via concerns), Generators, Views, Helper for fast Tree rendering and Admin UI.
8. If you have problems with TheComments, I'll try to help you via skype: **ilya.killich**
   
### TheComments based on:

1. [AwesomeNestedSet](https://github.com/collectiveidea/awesome_nested_set) - for comments threading
2. [TheSortableTree](https://github.com/the-teacher/the_sortable_tree) - for fast rendering of comments tree
3. [State Machine](https://github.com/pluginaweek/state_machine) - to provide easy and correct recalculation cache counters on states transitions