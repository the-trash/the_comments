module TheComments
  module Commentable

    extend ActiveSupport::Concern

    class_methods do
      # service method
      # only for development purposes => can takes a while
      def recalculate_comments_counters!
        self.all.each { |commentable| commentable.try :recalculate_comments_counters! }
      end
    end

    included do
      has_many :comments, as: :commentable

      # `define_denormalize_flags` - should be placed before title or url builder filters
      before_validation :define_denormalize_flags
      after_save        :denormalize_for_comments, if: -> { !id_changed? }
    end

    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    # Default Denormalization methods
    # Overwrite it in your Application
    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    # => 'My first blog post'
    def commentable_title
      try(:title) || TheComments.config.default_title
    end

    # => '/posts/1'
    def commentable_url
      ['', self.class.to_s.tableize, self.to_param].join('/')
    end

    # => 'draft'
    def commentable_state
      try(:state)
    end
    #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    # Helper methods
    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    def comments_sum
      published_comments_count + draft_comments_count
    end

    def recalculate_comments_counters!
      update_columns({
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
