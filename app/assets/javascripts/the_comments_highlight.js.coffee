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
