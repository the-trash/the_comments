class CommentSubscriberMailer < ActionMailer::Base
  default from: ::TheComments.config.default_mailer_email

  # TestMailer.test_mail.deliver
  def notificate email, comment, commenable
    mail(
      to: email,
      subject: "Новый комментарий",
      template_path: "the_comments/mailers",
      template_name: "new_comment"
    )
  end
end
