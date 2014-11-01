#= require jquery
#= require jquery_ujs
#= require jquery.data-role-block

#= require the_notification/vendors/toastr
#= require the_notification
#= require the_comments_default_notificator

#= require the_log
#= require the_comments

$ ->
  notificator = TheCommentsDefaultNotificator
  TheComments.init(notificator)
  TheCommentsHighlight.init()
