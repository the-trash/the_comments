# TIME HELPER
@unixsec = (t) -> Math.round(t.getTime() / 1000)

# INTERPOLATION HELPER
String::supplant = (o) ->
  @replace /{([^{}]*)}/g, (a, b) ->
    r = o[b]
    (if typeof r is "string" or typeof r is "number" then r else a)

# TheCommentsHighlight.init()
@TheCommentsHighlight = do ->
  highlight_anchor: ->
    hash = document.location.hash
    if hash.match('#comment_')
      $(hash).addClass 'highlighted'

  init: ->
    @highlight_anchor()

    $(window).on 'hashchange', =>
      $('.comment.highlighted').removeClass 'highlighted'
      @highlight_anchor()

# TheComments.init()
@TheComments = do ->
  comment_forms: "#new_comment, .reply_comments_form"

  i18n:
    server_error: "Server Error: {code} code"
    please_wait:  "Please wait for {sec} sec"
    succesful_created: "Comment was created"

  init: (@notificator) ->
    do @reply_button_init
    do @ajaxian_form_init
    do @new_comment_link_init
    do @new_comment_submit_btn_init

  clear_comment_form: ->
    $("input[name='comment[title]']").val('')
    $("textarea[name='comment[raw_content]']").val('')

  new_comment_link_init: ->
    $(document).on 'click', '#new_root_comment', ->
      $('.reply_comments_form').hide()
      $('.parent_id').val('')
      $('#new_comment').fadeIn()
      false

  reply_button_init: ->
    $(document).on 'click', '.reply_link', ->
      link    = $ @
      comment = link.parent().parent().parent()

      $(@comment_forms).hide()

      form = $('#new_comment')
              .clone()
              .removeAttr('id')
              .addClass('reply_comments_form')

      comment_id = comment.data('comment-id')
      $('.parent_id', form).val comment_id

      comment.siblings('.form_holder').html(form)
      form.fadeIn()
      false

  ajaxian_form_init: ->
    # ERROR
    $(document).on 'ajax:error', @comment_forms, (request, response, status) ->
      form = $ @
      $('input[type=submit]', form).show()

      if errors = response?.responseJSON?.errors
        TheComments.notificator.show_errors(errors, form)
      else
        TheComments.notificator.show_error(
          TheComments.i18n.server_error.supplant({ code: response.status }),
          form
        )

    # SUCCESS
    $(document).on 'ajax:success', @comment_forms, (request, response, status) ->
      form = $ @
      $('input[type=submit]', form).show()

      anchor = $(response).find('.comment').attr('id')
      TheComments.clear_comment_form()

      form.hide()
      $('.parent_id').val('')
      $('#new_comment').fadeIn()

      tree = form.parent().siblings('.nested_set')
      tree = $('ol.comments_tree') if tree.length is 0
      tree.append(response)

      TheComments.notificator.show_flash({
        flash: [ TheComments.i18n.succesful_created ]
      })

      document.location.hash = anchor

  new_comment_submit_btn_init: ->
    window.tolerance_time_start = unixsec(new Date)
    tolerance_time = $('[data-comments-tolarance-time]').first().data('comments-tolarance-time')

    # Button Click => AJAX Before Send
    submits = '#new_comment input[type=submit], .reply_comments_form input[type=submit]'

    $(document).on 'click', submits, (e) =>
      button    = $ e.target
      form      = button.parents('form').first()
      time_diff = unixsec(new Date) - window.tolerance_time_start

      if tolerance_time && (time_diff < tolerance_time)
        delta = tolerance_time - time_diff

        TheComments.notificator.show_error(
          TheComments.i18n.please_wait.supplant({ sec: delta }),
          form
        )

        return false

      $('.tolerance_time').val time_diff
      button.hide()
      true
