class TheCommentsAntiSpamWorker
  include Sidekiq::Worker

  sidekiq_options queue: :the_comments_workers,
                  retry: true,
                  backtrace: true

  # TheCommentsAntiSpamWorker.perform_async(comment_id)
  # TheCommentsAntiSpamWorker.new.perform(comment_id)
  def perform(comment_id, request_data)
    comment = Comment.find(comment_id)
    comment.antispam_services_check_batch(request_data)
  end
end
