# FORM CLEANER
@clear_comment_form = ->
  $('.error_notifier', '#new_comment, .comments_tree').hide()
  $("input[name='comment[title]']").val('')
  $("textarea[name='comment[raw_content]']").val('')

# NOTIFIER
@comments_error_notifier = (form, text) ->
  form.children('.error_notifier').empty().hide().append(text).show()

@unixsec = (t) -> Math.round(t.getTime() / 1000)

# HIGHTLIGHT ANCHOR
@highlight_anchor = ->
  hash = document.location.hash
  if hash.match('#comment_')
    $(hash).addClass 'highlighted'

$ ->
  window.tolerance_time_start = unixsec(new Date)
  comment_forms = "#new_comment, .reply_comments_form"

  # AJAX Before Send
  submits = '#new_comment input[type=submit], .reply_comments_form input[type=submit]'
  $(document).on 'click', submits, (e) ->
    $(e.target).prop 'disabled', true
    log $(e.target)
    time_diff = unixsec(new Date) - window.tolerance_time_start
    $('.tolerance_time').val time_diff
    true

  # AJAX ERROR
  $(document).on 'ajax:error', comment_forms, (request, response, status) ->
    form = $ @
    $('input[type=submit]', form).prop 'disabled', false
    comments_error_notifier(form, "<p><b>Server Error:</b> #{response.status}</p>")

  # CONTROLS
  ctrls = $('.controls')
  
  ctrls.on 'ajax:success', '.to_published', (request, response, status) ->
    $(@).hide().siblings('.to_draft').show()

  ctrls.on 'ajax:success', '.to_draft', (request, response, status) ->
    $(@).hide().siblings('.to_published').show()

  ctrls.on 'ajax:success', '.to_spam, .to_deleted', (request, response, status) ->
    $(@).parents('li').first().hide()

  # COMMENT FORMS
  $(document).on 'ajax:success', comment_forms, (request, response, status) ->
    form = $ @
    $('input[type=submit]', form).prop 'disabled', false

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
      error_msgs = ''
      for error, messages of response.errors
        error_msgs += "<p><b>#{error}</b>: #{messages.join(', ')}</p>"

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
    form.fadeIn()
    false

$ ->
  # ANCHOR HIGHLIGHT
  highlight_anchor()

  $(window).on 'hashchange', ->
    $('.comment.highlighted').removeClass 'highlighted'
    highlight_anchor()