#= require ./the_string_interpolate
#= require ./the_comments_highlight

# BASE HELPERS
@unixsec = (t) -> Math.round(t.getTime() / 1000)

# data-block (@@) for containers
# data-role (@) for items with handlers or values

# Add to your app:
#
# Notificator as dependency injection
#
#
# $ ->
#   TheComments.init( TheCommentsDefaultNotificator )

@TheComments = do ->
  #####################################################
  # MODULE COMMON VARS
  #####################################################
  comment_forms: "@new_comment, .reply_comments_form"
  submits:       '@@comments input[type=submit]'

  i18n:
    server_error: "Server Error: {code} code"
    please_wait:  "Please wait for {sec} sec"
    succesful_created: "Comment was created"

  #####################################################
  # MODULE INITIALIZER
  #####################################################
  init: (@notificator) ->
    do @reply_button_init
    do @ajaxian_form_init
    do @enable_submit_button
    do @new_comment_link_init
    do @new_comment_submit_btn_init
    do @tolerance_time_protection_init

  #####################################################
  # FORM AJAXIAN BEHAVIOR
  #####################################################
  ajaxian_form_init: ->
    # SUCCESS
    $(document).on 'ajax:success', @comment_forms, (request, data, status) =>
      form = $ request.currentTarget
      do @enable_submit_button

      # clean up env
      form.hide()
      $('@parent_id').val('')
      $('@new_comment').fadeIn()
      @clear_comment_form()

      # append to nested tree or to root level?
      tree = form.parent().siblings('@@nested_set')
      tree = $('@@comments_tree') if tree.length is 0

      # append comment
      tree.append(data.comment)

      # show notification
      @notificator.show_flash({
        flash: [ @i18n.succesful_created ]
      })

      # set anchor
      anchor = $(data).find('@comment').attr('id')
      document.location.hash = anchor

    # ERROR
    $(document).on 'ajax:error', @comment_forms, (request, response, status) =>
      form = $ request.currentTarget
      do @enable_submit_button

      if errors = response?.responseJSON?.errors
        @notificator.show_errors(errors, form)
      else
        @notificator.show_error(
          @i18n.server_error._interpolate({ code: response.status }),
          form
        )

  #####################################################
  # LINKS/BUTTONS INITIALIZERS
  #####################################################
  new_comment_link_init: ->
    $(document).on 'click', '@new_root_comment', (e) =>
      $('@reply_comments_form').remove()
      $('@new_comment').fadeIn()
      $('@parent_id').val('')
      false

  new_comment_submit_btn_init: ->
    # Button Click => de-facto: AJAX Before Send
    $(document).on 'click', @submits, (e) =>
      button    = $ e.currentTarget
      form      = button.parents('form').first()

      return false unless @acceptable_tolerance_time_for(form)
      do @disable_submit_button
      true

  reply_button_init: ->
    $(document).on 'click', '@reply_link', (e) =>
      link    = $ e.currentTarget
      comment = link.parents('@comment')

      # reset 'new comment' forms
      $(@comment_forms).hide()
      $('@reply_comments_form').remove()
      form = $('@new_comment').clone().addRole('reply_comments_form')

      comment_id = comment.data('comment-id')
      $("@parent_id", form).val comment_id

      comment.siblings('@@form_holder').html(form)
      form.fadeIn()
      false

  #####################################################
  # HELPERS
  #####################################################
  disable_submit_button: ->
    $(@submits).prop('disabled', true)

  enable_submit_button: ->
    $(@submits).prop('disabled', false)

  clear_comment_form: ->
    $("@@comments input[name='comment[title]']").val('')
    $("@@comments textarea[name='comment[raw_content]']").val('')

  #####################################################
  # PROTECTION AND ANTI-SPAM HELPERS
  #####################################################
  tolerance_time_protection_init: ->
    window.tolerance_time_start = unixsec(new Date)

  acceptable_tolerance_time_for: (form) ->
    tolerance_time = $('@tolarance_time_holder').data('comments-tolarance-time')
    time_diff      = unixsec(new Date) - window.tolerance_time_start
    delta          = tolerance_time - time_diff

    $('@tolerance_time').val time_diff

    return true unless tolerance_time && (time_diff < tolerance_time)

    @notificator.show_error(
      @i18n.please_wait._interpolate({ sec: delta }),
      form
    )

    false
