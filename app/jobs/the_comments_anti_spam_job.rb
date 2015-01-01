class TheCommentsAntiSpamJob < ActiveJob::Base
  queue_as :the_comments_jobs

  # TheCommentsAntiSpamJob.perform_later(comment_id, { ... })
  # TheCommentsAntiSpamJob.perform_now(comment_id, { ... })
  def perform(comment_id, request_data)
    comment = Comment.find(comment_id)
    comment.antispam_services_check_batch(request_data)
  end
end
