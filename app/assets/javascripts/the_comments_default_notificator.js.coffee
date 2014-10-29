@TheCommentsDefaultNotificator = do ->
  show_error:  (error,   form) -> TheNotification.show_error  error
  show_errors: (errors,  form) -> TheNotification.show_errors errors
  show_flash:  (flashes, form) -> TheNotification.show_flash  flashes
