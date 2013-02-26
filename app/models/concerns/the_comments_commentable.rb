module TheCommentsCommentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable

    def commentable_title
      try(:title) || try(:name) || try(:login)
    end

    def commentable_url
      [self.class.to_s.tableize, self.to_param].join('/')
    end

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