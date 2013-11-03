# ERROR MSG BUILDER
@comments_errors_builder = (errors) ->
  error_msgs = ''
  for error in errors
    error_msgs += "<p><b>#{ error }</b></p>"
  error_msgs

# FORM CLEANER
@clear_comment_form = ->
  $('.error_notifier', '#new_comment, .comments_tree').hide()
  $("input[name='comment[title]']").val('')
  $("textarea[name='comment[raw_content]']").val('')

# NOTIFIER
@comments_error_notifier = (form, text) ->
  form.children('.error_notifier').empty().hide().append(text).show()

# TIME HELPER
@unixsec = (t) -> Math.round(t.getTime() / 1000)

# HIGHTLIGHT ANCHOR
@highlight_anchor = ->
  hash = document.location.hash
  if hash.match('#comment_')
    $(hash).addClass 'highlighted'

$ ->
  window.tolerance_time_start = unixsec(new Date)
  tolerance_time = $('[data-comments-tolarance-time]').first().data('comments-tolarance-time')

  # Button Click => AJAX Before Send
  submits = '#new_comment input[type=submit], .reply_comments_form input[type=submit]'

  $(document).on 'click', submits, (e) ->
    button    = $ e.target
    form      = button.parents('form').first()
    time_diff = unixsec(new Date) - window.tolerance_time_start

    if tolerance_time && (time_diff < tolerance_time)
      delta  = tolerance_time - time_diff
      error_msgs = comments_errors_builder(["Please wait #{delta} secs"])
      comments_error_notifier(form, error_msgs)
      return false

    $('.tolerance_time').val time_diff
    button.hide()
    true

  ################ COMMENTS FORMS ################
  comment_forms  = "#new_comment, .reply_comments_form"

  # ERROR
  $(document).on 'ajax:error', comment_forms, (request, response, status) ->
    form = $ @
    $('input[type=submit]', form).show()
    error_msgs = comments_errors_builder(["Server Error: #{response.status}"])
    comments_error_notifier(form, error_msgs)

  # SUCCESS
  $(document).on 'ajax:success', comment_forms, (request, response, status) ->
    form = $ @
    $('input[type=submit]', form).show()

    if typeof(response) is 'string'
      anchor = $(response).find('.comment').attr('id')
      clear_comment_form()
      form.hide()
      $('.parent_id').val('')
      $('#new_comment').fadeIn()
      tree = form.parent().siblings('.nested_set')
      tree = $('ol.comments_tree') if tree.length is 0
      tree.append(response)
      document.location.hash = anchor
    else
      error_msgs = comments_errors_builder(response.errors)
      comments_error_notifier(form, error_msgs)

  # NEW ROOT BUTTON
  $(document).on 'click', '#new_root_comment', ->
    $('.reply_comments_form').hide()
    $('.parent_id').val('')
    $('#new_comment').fadeIn()
    false

  # REPLY BUTTON
  $(document).on 'click', '.reply_link', ->
    link    = $ @
    comment = link.parent().parent().parent()
  
    $(comment_forms).hide()
    form = $('#new_comment').clone().removeAttr('id').addClass('reply_comments_form')

    comment_id = comment.data('comment-id')
    $('.parent_id', form).val comment_id

    comment.siblings('.form_holder').html(form)
    $('.error_notifier', form).empty().hide()
    form.fadeIn()
    false

$ ->
  # ANCHOR HIGHLIGHT
  highlight_anchor()

  $(window).on 'hashchange', ->
    $('.comment.highlighted').removeClass 'highlighted'
    highlight_anchor()