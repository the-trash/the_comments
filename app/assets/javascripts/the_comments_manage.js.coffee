$ ->
  hide_comment_panel = (btn) -> $(btn).parents('.panel').slideUp()

  comments = $ '.comments'

  # CONTROLS
  comments.on 'click', 'a.additional_info', ->
    btn    = $ @
    holder = btn.parents('.panel-body')
    holder.find('div.additional_info').slideToggle()
    false

  comments.on 'click', 'a.edit', ->
    btn    = $ @
    holder = btn.parents('.panel-body')
    holder.find('.edit_form, .comment_body, a.edit').toggle()
    false

  comments.on 'ajax:success', '.to_published, .to_draft, .to_spam, .to_deleted', ->
    hide_comment_panel @

  # Edit form
  comments.on 'ajax:success', '.edit_comment', (request, response, status) ->
    form   = $ @
    holder = form.parents('.panel-body')
    holder.find('.edit_form, .comment_body, a.edit').toggle()
    holder.find('.comment_body').replaceWith response