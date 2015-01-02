@TheCommentsManagePanel = do ->
  init: ->
    hide_comment_panel = (btn) -> $(btn).parents('@@panel').slideUp()

    comments = $ '@@comments'

    # CONTROLS
    comments.on 'click', '@comment_info', ->
      btn    = $ @
      holder = btn.parents('@@panel-body')
      holder.find('@@comment_info').slideToggle()
      false

    comments.on 'click', '@comment_edit', ->
      btn    = $ @
      holder = btn.parents('@@panel-body')
      holder.find('@@comment_edit_form, @@comment_body, @comment_edit').toggle()
      false

    comments.on 'ajax:success', '@to_published, @to_draft, @to_spam, @to_deleted', ->
      hide_comment_panel @

    # Edit form
    comments.on 'ajax:success', '@@comment_edit_form', (request, response, status) ->
      form   = $ @
      holder = form.parents('@@panel-body')
      holder.find('@@comment_edit_form, @@comment_body, @comment_edit').toggle()
      holder.find('@@comment_body').replaceWith response
