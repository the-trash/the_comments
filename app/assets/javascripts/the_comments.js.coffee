# FORM CLEANER
@clear_comment_form = ->
  $('.error_notifier', '#new_comment, .comments_tree').hide()
  $("input[name='comment[title]']").val('')
  $("textarea[name='comment[raw_content]']").val('')

# NOTIFIER
@comments_error_notifier = (form, text) ->
  form.children('.error_notifier').empty().hide().append(text).show()

@unixsec = (t) -> Math.round(t.getTime() / 1000)

$ ->
  window.tolerance_time_start = unixsec(new Date)
  comment_forms = $("#new_comment, .reply_comments_form")

  # AJAX Before Send
  $("input[type=submit]", comment_forms).live 'click', ->
    time_diff = unixsec(new Date) - window.tolerance_time_start
    $('.tolerance_time').val time_diff
    true

  # AJAX ERROR
  comment_forms.live 'ajax:error', (request, response, status) ->
    form = $ @
    comments_error_notifier(form, "<p><b>Server Error:</b> #{response.status}</p>")

  # AJAX SUCCESS
  comment_forms.live 'ajax:success', (request, response, status) ->
    form = $ @

    if typeof(response) is 'string'
      clear_comment_form()
      form.hide()
      $('#new_comment').fadeIn()
      tree = form.parent().siblings('.nested_set')
      tree = $('ol.comments_tree') if tree.length is 0
      tree.append(response)
    else
      error_msgs = ''
      for error, messages of response.errors
        error_msgs += "<p><b>#{error}</b>: #{messages.join(', ')}</p>"

      comments_error_notifier(form, error_msgs)

  # NEW ROOT BUTTON
  $('#new_root_comment').live 'click', ->
    $('.reply_comments_form').hide()
    $('#new_comment').fadeIn()

    false

  # REPLY BUTTON
  $('.reply_link').live 'click', ->
    link    = $ @
    comment = link.parent().parent().parent()
  
    $('#new_comment, .reply_comments_form').hide()
    form = $('#new_comment').clone().removeAttr('id').addClass('reply_comments_form')

    comment_id = comment.data('comment-id')
    $('.parent_id', form).val comment_id

    comment.siblings('.form_holder').html(form)
    form.fadeIn()

    false

  # CONTROLS
  $('.to_spam, .to_deleted').live 'ajax:success', ->
    $(@).parents('li').first().hide()