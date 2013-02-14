$ ->
  $('#new_root_comment').live 'click', ->
    $('.reply_comments_form').hide()
    $('#new_comment').fadeIn()

    false

  $('.comments_tree a.reply').live 'click', ->
    link   = $ @
    parent = link.parent()
    holder = parent.parent()
  
    _form = $('#new_comment').hide()
    $('.reply_comments_form').hide()
    form  = _form.clone().removeAttr('id').addClass('reply_comments_form')

    comment_id = parent.data('comment-id')
    $('.parent_id', form).val comment_id

    $('.form_holder', holder).html(form)
    form.fadeIn()

    false
