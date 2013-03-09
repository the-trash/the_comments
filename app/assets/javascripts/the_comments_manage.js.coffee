$ ->
  # CONTROLS
  holder = $('.comments_list')
  
  holder.on 'ajax:success', '.to_published', (request, response, status) ->
    link = $ @
    log link.parents('.item')
    link.parents('.item').first().attr('class', 'item published')

  holder.on 'ajax:success', '.to_draft', (request, response, status) ->
    link = $ @
    log link.parents('.item')
    link.parents('.item').first().attr('class', 'item draft')

  holder.on 'ajax:success', '.to_spam, .to_deleted', (request, response, status) ->
    $(@).parents('li').first().hide()

  $('.comments_tree').on 'ajax:success', '.delete', (request, response, status) ->
    $(@).parents('li').first().hide()

  # INPLACE EDIT
  inplace_forms = '.comments_list .form form'
  $(document).on 'ajax:success', inplace_forms, (request, response, status) ->
    form = $ @
    item = form.parents('.item')
    item.children('.body').html(response).show()
    item.children('.form').hide()

  # FOR MANAGE SECTION
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

  # BLACK LIST
  holder = $('.black_list')

  holder.on 'ajax:success', '.to_warning', (request, response, status) ->
    link = $ @
    li = link.parents('li').first()
    li.attr 'class', 'warning'
    li.find('.state').html 'warning'

  holder.on 'ajax:success', '.to_banned', (request, response, status) ->
    link = $ @
    li = link.parents('li').first()
    li.attr 'class', 'banned'
    li.find('.state').html 'banned'