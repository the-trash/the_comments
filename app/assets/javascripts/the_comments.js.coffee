# BASE HELPERS
@unixsec = (t) -> Math.round(t.getTime() / 1000)

# INTERPOLATION HELPER
String::_interpolate = (o) ->
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
  comment_forms: "[data-role='new_comment'], .reply_comments_form"
  submits:       '.comments input[type=submit]'

  i18n:
    server_error: "Server Error: {code} code"
    please_wait:  "Please wait for {sec} sec"
    succesful_created: "Comment was created"

  init: (@notificator) ->
    do @reply_button_init
    do @ajaxian_form_init
    do @enable_submit_button
    do @new_comment_link_init
    do @new_comment_submit_btn_init

  disable_submit_button: ->
    $(@submits).prop('disabled', true)

  enable_submit_button: ->
    $(@submits).prop('disabled', false)

  clear_comment_form: ->
    $("input[name='comment[title]']").val('')
    $("textarea[name='comment[raw_content]']").val('')

  new_comment_link_init: ->
    $(document).on 'click', '#new_root_comment', (e) =>
      $('@reply_comments_form').hide()
      $('@new_comment').fadeIn()
      $('@parent_id').val('')
      false

  reply_button_init: ->
    $(document).on 'click', '.reply_link', (e) =>
      link    = $ e.currentTarget
      comment = link.parents('.comment')

      $(@comment_forms).hide()
      form = $('@new_comment').clone().addRole('reply_comments_form')

      comment_id = comment.data('comment-id')
      $("@parent_id", form).val comment_id

      comment.siblings('.form_holder').html(form)
      form.fadeIn()
      false

  ajaxian_form_init: ->
    # ERROR
    $(document).on 'ajax:error', @comment_forms, (request, response, status) ->
      form = $ @
      do TheComments.enable_submit_button

      if errors = response?.responseJSON?.errors
        TheComments.notificator.show_errors(errors, form)
      else
        TheComments.notificator.show_error(
          TheComments.i18n.server_error._interpolate({ code: response.status }),
          form
        )

    # SUCCESS
    $(document).on 'ajax:success', @comment_forms, (request, response, status) =>
      form = $ request.currentTarget
      do @enable_submit_button

      # clean up env
      form.hide()
      $('@parent_id').val('')
      $('@new_comment').fadeIn()
      TheComments.clear_comment_form()

      # append to nested tree or to root level?
      tree = form.parent().siblings('.nested_set')
      tree = $('ol.comments_tree') if tree.length is 0

      # append comment
      tree.append(response)

      # show notification
      @notificator.show_flash({
        flash: [ @i18n.succesful_created ]
      })

      # set anchor
      anchor = $(response).find('.comment').attr('id')
      document.location.hash = anchor

  new_comment_submit_btn_init: ->
    window.tolerance_time_start = unixsec(new Date)
    tolerance_time = $('[data-comments-tolarance-time]').data('comments-tolarance-time')

    # Button Click => AJAX Before Send
    $(document).on 'click', @submits, (e) =>
      button    = $ e.currentTarget
      form      = button.parents('form').first()
      time_diff = unixsec(new Date) - window.tolerance_time_start

      if tolerance_time && (time_diff < tolerance_time)
        delta = tolerance_time - time_diff

        @notificator.show_error(
          @i18n.please_wait._interpolate({ sec: delta }),
          form
        )

        return false

      $('.tolerance_time').val time_diff
      do @disable_submit_button

      true
