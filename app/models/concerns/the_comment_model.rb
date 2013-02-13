module TheCommentModel
  extend ActiveSupport::Concern

  ANTICAPTCHA_TOKENS = %w[ <!> *?* <<<> ,!, ??! ]

  included do
    # Nested Set
    acts_as_nested_set scope: [:commentable_type, :commentable_id]

    # TheSortableTree
    include TheSortableTree::Scopes

    def self.anticaptcha_token
      ANTICAPTCHA_TOKENS
    end

    attr_accessible :user, :title, :contacts, :raw_content, :view_token

    # relations
    belongs_to :user
    belongs_to :holder, class_name: :User
    belongs_to :commentable, polymorphic: true

    # callbacks
    before_create :define_holder, :define_anchor
    after_create  :update_cache_counters

    # :draft | :published | :deleted
    state_machine :state, :initial => :draft do
      # events
      event :to_draft do 
        transition all => :draft
      end

      event :to_published do
        transition all => :published
      end

      event :to_deleted do
        transition all => :deleted
      end

      # cache counters
      after_transition any => any do |comment|
        @owner  = comment.user
        @holder = comment.holder
      end

      # Draft
      after_transition any => :draft do |comment|
        @owner.try(:increment!,  :draft_comments_count)
        @holder.try(:increment!, :draft_comcoms_count)
      end

      after_transition :draft => any do |comment|
        @owner.try(:decrement!,  :draft_comments_count)
        @holder.try(:decrement!, :draft_comcoms_count)
      end

      # Published
      after_transition any => :published do |comment|
        @owner.try(:increment!,  :published_comments_count)
        @holder.try(:increment!, :published_comcoms_count)
      end

      after_transition :published => any do |comment|
        @owner.try(:decrement!,  :published_comments_count)
        @holder.try(:decrement!, :published_comcoms_count)
      end

      # Deleted
      after_transition any => :deleted do |comment|
        @owner.try(:decrement!,  :total_comments_count)
        @holder.try(:decrement!, :total_comcoms_count)

        @owner.try(:increment!,  :deleted_comments_count)
        @holder.try(:increment!, :deleted_comcoms_count)
      end

      after_transition :deleted => any do |comment|
        @owner.try(:increment!,  :total_comments_count)
        @holder.try(:increment!, :total_comcoms_count)

        @owner.try(:decrement!,  :deleted_comments_count)
        @holder.try(:decrement!, :deleted_comcoms_count)
      end
    end

    private

    def define_anchor
      self.anchor = SecureRandom.hex[0..5]
    end

    def define_holder
      self.holder = self.commentable.user
    end

    def update_cache_counters
      owner       = self.user
      holder      = self.holder
      commentable = self.commentable

      owner.try(:increment!, :total_comments_count)
      owner.try(:increment!, :draft_comments_count)

      holder.try(:increment!, :total_comcoms_count)
      holder.try(:increment!, :draft_comcoms_count)

      commentable.try(:increment!, :total_comments_count)
      commentable.try(:increment!, :draft_comments_count)
    end
  end

end