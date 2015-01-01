class TheCommentsNotificationsJob < ActiveJob::Base
  queue_as :the_comments_jobs

  # TheCommentsNotificationsJob.perform_later(email, comment_id)
  # TheCommentsNotificationsJob.perform_now(email, comment_id)
  def perform(email, comment_id)
    comment = Comment.find(comment_id)
    CommentSubscriberMailer.notificate(email, comment).deliver
  end
end

# include Sidekiq::Worker
#
# sidekiq_options queue: :the_comments_workers,
#                 retry: true,
#                 backtrace: true
