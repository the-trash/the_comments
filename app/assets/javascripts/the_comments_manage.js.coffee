$ ->
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

  comments.on 'ajax:success', '.to_published', (request, response, status) ->
    btn    = $ @
    holder = btn.parents('.panel')
    holder.removeClass('panel-warning').addClass('panel-primary')
    holder.find('.to_draft, .to_published').toggle()

  comments.on 'ajax:success', '.to_draft', (request, response, status) ->
    btn    = $ @
    holder = btn.parents('.panel')
    holder.removeClass('panel-primary').addClass('panel-warning')
    holder.find('.to_draft, .to_published').toggle()

  comments.on 'ajax:success', '.to_spam, .to_deleted', (request, response, status) ->
    $(@).parents('.panel').hide()

  # Edit form
  comments.on 'ajax:success', '.edit_comment', (request, response, status) ->
    form   = $ @
    holder = form.parents('.panel-body')
    holder.find('.edit_form, .comment_body, a.edit').toggle()
    holder.find('.comment_body').replaceWith response