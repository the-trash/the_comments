module TheCommentsCommentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable
    
    # TODO: update requests reduction
    # *define_denormalize_flags* - should be placed before
    # title or url builder filters
    before_validation :define_denormalize_flags
    after_save        :denormalize_for_comments

    def commentable_title
      try(:title) || 'Undefined title'
    end

    def commentable_url
      # /pages/1
      ['', self.class.to_s.tableize, self.to_param].join('/')
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

    private

    def define_denormalize_flags
      @_commentable_title = commentable_title
      @_commentable_url   = commentable_url
    end

    def denormalize_for_comments
      title_changed = @_commentable_title != commentable_title
      url_changed   = @_commentable_url   != commentable_url

      if title_changed || url_changed
        Comment.where(commentable: self).update_all(commentable_title: commentable_title, commentable_url: commentable_url)      
      end
    end
  end
end