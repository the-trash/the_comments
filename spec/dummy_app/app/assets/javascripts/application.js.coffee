#= require jquery
#= require jquery_ujs

#= require the_notification/vendors/toastr
#= require the_notification

#= require the_log
#= require the_comments

$ ->
  TheComments.init()
  TheCommentsHighlight.init()
