class TheCommentsNotificationsJob < ActiveJob::Base
  queue_as :the_comments_jobs

  # TheCommentsNotificationsJob.perform_later(email, comment_id)
  # TheCommentsNotificationsJob.perform_now(email, comment_id)
  def perform(email, comment_id)
    comment = Comment.find(comment_id)
    CommentSubscriberMailer.notificate(email, comment).deliver_now
  end
end

# retry: true,
# backtrace: true
