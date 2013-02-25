module TheCommentsCommentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable

    def comments_sum
      published_comments_count + draft_comments_count
    end

    def recalculate_comments_counters
      self.draft_comments_count     = comments.with_state(:draft).count
      self.published_comments_count = comments.with_state(:published).count
      self.deleted_comments_count   = comments.with_state(:deleted).count
      save
    end
  end
end