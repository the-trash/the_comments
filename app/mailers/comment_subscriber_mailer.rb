class CommentSubscriberMailer < ActionMailer::Base
  default from: ::TheComments.config.default_mailer_email

  include TheCommentsViewHelper

  # CommentSubscriberMailer.notificate(email, comment).deliver_now
  # CommentSubscriberMailer.notificate(email, comment).deliver_later
  def notificate email, comment
    @email       = email
    @comment     = comment
    @commentable = comment.commentable

    mail(
      to: email,
      subject: "TheComments::New Comment",
      template_path: comment_template('mailers'),
      template_name: "new_comment"
    )
  end
end
