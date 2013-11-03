module TheComments
  module Commentable

    extend ActiveSupport::Concern
    
    included do
      has_many :comments, as: :commentable

      # *define_denormalize_flags* - should be placed before title or url builder filters
      before_validation :define_denormalize_flags
      after_save        :denormalize_for_comments, if: -> { !id_changed? }
    end

    # Default Denormalization methods
    # Overwrite it with your Application
    def commentable_title
      # My first blog post
      try(:title) || TheComments.config.default_title
    end

    def commentable_url
      # /posts/1
      ['', self.class.to_s.tableize, self.to_param].join('/')
    end

    def commentable_state
      # 'draft'
      try(:state)
    end

    # Helper methods
    def comments_sum
      published_comments_count + draft_comments_count
    end

    def recalculate_comments_counters!
      update_attributes!({
        draft_comments_count:     comments.with_state(:draft).count,
        published_comments_count: comments.with_state(:published).count,
        deleted_comments_count:   comments.with_state(:deleted).count
      })
    end

    private

    def define_denormalize_flags
      @trackable_commentable_title = commentable_title
      @trackable_commentable_state = commentable_state
      @trackable_commentable_url   = commentable_url
    end

    def denormalization_fields_changed?
      a = @trackable_commentable_title != commentable_title
      b = @trackable_commentable_state != commentable_state
      c = @trackable_commentable_url   != commentable_url
      a || b || c
    end

    def denormalize_for_comments
      if denormalization_fields_changed?
        comments.update_all({
          commentable_title: commentable_title,
          commentable_state: commentable_state,
          commentable_url:   commentable_url
        })
      end 
    end
  end
end