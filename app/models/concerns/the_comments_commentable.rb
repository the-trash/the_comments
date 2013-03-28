module TheCommentsCommentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable

    # *define_denormalize_flags* - should be placed before title or url builder filters
    before_validation :define_denormalize_flags
    after_save        :denormalize_for_comments
  end

  def commentable_title
    try(:title) || TheComments.config.default_title
  end

  def commentable_url
    # /pages/1
    ['', self.class.to_s.tableize, self.to_param].join('/')
  end

  def commentable_state
    # 'draft'
    try(:state)
  end

  def comments_sum
    published_comments_count + draft_comments_count
  end

  def recalculate_comments_counters!
    self.draft_comments_count     = comments.with_state(:draft).count
    self.published_comments_count = comments.with_state(:published).count
    self.deleted_comments_count   = comments.with_state(:deleted).count
    save
  end

  private

  def define_denormalize_flags
    @trackable_commentable_title = commentable_title
    @trackable_commentable_state = commentable_state
    @trackable_commentable_url   = commentable_url
  end

  # Can you make it better? I don't know how.
  def denormalization_fields_changed?
    @title_field_changed = @trackable_commentable_title != commentable_title
    @state_field_changed = @trackable_commentable_state != commentable_state
    @url_field_changed   = @trackable_commentable_url   != commentable_url
    @title_field_changed || @url_field_changed || @state_field_changed
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