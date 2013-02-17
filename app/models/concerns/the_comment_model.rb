module TheCommentModel
  extend ActiveSupport::Concern

  included do
    # Nested Set
    acts_as_nested_set scope: [:commentable_type, :commentable_id]
    attr_accessible :parent_id

    # TheSortableTree
    include TheSortableTree::Scopes

    attr_accessible :user, :title, :contacts, :raw_content, :view_token

    validates :title, presence: true
    validates :raw_content, presence: true

    # relations
    belongs_to :user
    belongs_to :holder, class_name: :User
    belongs_to :commentable, polymorphic: true

    # callbacks
    before_create :define_holder, :define_anchor, :prepare_content
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
        @owner       = comment.user
        @holder      = comment.holder
        @commentable = comment.commentable
      end

      [:draft, :published, :deleted].each do |name|
        after_transition any - name => name do
          @holder.try      :increment!, "#{name}_comcoms_count"
          @owner.try       :increment!, "#{name}_comments_count"
          @commentable.try :increment!, "#{name}_comments_count"
        end

        after_transition name => any - name do
          @holder.try      :decrement!, "#{name}_comcoms_count"
          @owner.try       :decrement!, "#{name}_comments_count"
          @commentable.try :decrement!, "#{name}_comments_count"
        end
      end

      # update total counter
      after_transition [:draft, :published] => :deleted do
        @holder.try      :decrement!, :total_comcoms_count
        @owner.try       :decrement!, :total_comments_count
        @commentable.try :decrement!, :total_comments_count
      end

      after_transition :deleted => [:draft, :published] do
        @holder.try      :increment!, :total_comcoms_count
        @owner.try       :increment!, :total_comments_count
        @commentable.try :increment!, :total_comments_count
      end
    end

    private

    def define_anchor
      self.anchor = SecureRandom.hex[0..5]
    end

    def define_holder
      self.holder = self.commentable.user
    end

    def prepare_content
      self.content = self.raw_content
    end

    def update_cache_counters
      owner       = self.user
      holder      = self.holder
      commentable = self.commentable

      owner.try(:increment!, :total_comments_count)
      owner.try(:increment!, :draft_comments_count)

      commentable.try(:increment!, :total_comments_count)
      commentable.try(:increment!, :draft_comments_count)

      holder.try(:increment!, :total_comcoms_count)
      holder.try(:increment!, :draft_comcoms_count)
    end
  end

end