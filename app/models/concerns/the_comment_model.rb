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

    # :not_approved | :approved | :deleted
    state_machine :state, :initial => :not_approved do
      # events
      event :to_not_approved do 
        transition all => :not_approved
      end

      event :to_approved do
        transition all => :approved
      end

      event :to_deleted do
        transition all => :deleted
      end

      # cache counters
      after_transition any => any do |comment|
        @owner  = comment.user
        @holder = comment.holder
      end

      # Deleted
      after_transition any => :deleted do |comment|
        @owner.try(:decrement!,  :total_comments_count)
        @holder.try(:decrement!, :total_comcoms_count)

        @owner.try(:increment!,  :del_comments_count)
        @holder.try(:increment!, :del_comcoms_count)
      end

      after_transition :deleted => any do |comment|
        @owner.try(:increment!,  :total_comments_count)
        @holder.try(:increment!, :total_comcoms_count)

        @owner.try(:decrement!,  :del_comments_count)
        @holder.try(:decrement!, :del_comcoms_count)
      end

      # Approved
      after_transition any => :approved do |comment|
        @owner.try(:increment!,  :approved_comments_count)
        @holder.try(:increment!, :approved_comcoms_count)
      end

      after_transition :approved => any do |comment|
        @owner.try(:decrement!,  :approved_comments_count)
        @holder.try(:decrement!, :approved_comcoms_count)
      end

      # Not approved
      after_transition any => :not_approved do |comment|
        @owner.try(:increment!,  :new_comments_count)
        @holder.try(:increment!, :new_comcoms_count)
      end

      after_transition :not_approved => any do |comment|
        @owner.try(:decrement!,  :new_comments_count)
        @holder.try(:decrement!, :new_comcoms_count)
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
      owner  = self.user
      holder = self.holder

      owner.try(:increment!, :total_comments_count)
      owner.try(:increment!, :new_comments_count)

      holder.try(:increment!, :total_comcoms_count)
      holder.try(:increment!, :new_comcoms_count)
    end
  end

end