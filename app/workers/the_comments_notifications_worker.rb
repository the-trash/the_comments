class TheCommentsNotificationsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :the_comments_workers,
                  retry: true,
                  backtrace: true

  # TheCommentsNotificationsWorker.perform_async(email, comment_id)
  def perform(email, comment_id)
    comment = Comment.find(comment_id)
    CommentSubscriberMailer.notificate(email, comment).deliver
  end
end
