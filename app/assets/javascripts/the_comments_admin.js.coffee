$ ->
  list = $('.comments_list')

  list.on 'click', '.controls a.view', ->
    form = $(@).parents('div.form')
    body = form.siblings('.body')  
    body.show()
    form.hide()
    false

  list.on 'click', '.controls a.edit', ->
    body = $(@).parents('div.body')
    form = body.siblings('.form')
    body.hide()
    form.show()
    false

  list.on 'click', '.controls a.to_published', ->
    log 'pressed'
    false

  list.on 'click', '.controls a.to_draft', ->
    log 'pressed'
    false

  list.on 'click', '.controls a.to_spam', ->
    log 'pressed'
    false

  list.on 'click', '.controls a.to_deleted', ->
    log 'pressed'
    false
