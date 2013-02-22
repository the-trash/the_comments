module TheCommentModels
  module Commentable
    extend ActiveSupport::Concern

    included do
      has_many :comments, as: :commentable

      def recalculate_comments_counters
        self.draft_comments_count     = comments.with_state(:draft).count
        self.published_comments_count = comments.with_state(:published).count
        self.deleted_comments_count   = comments.with_state(:deleted).count
        save
      end
    end
  end

  module User
    extend ActiveSupport::Concern
    
    included do
      has_many :comments
      has_many :comcoms, class_name: :Comment, foreign_key: :holder_id

      def commentable_list
        []
      end

      def recalculate_comments_counters
        [:comments, :comcoms].each do |name|
          if respond_to? name
            send "draft_#{name}_count=",     send(name).with_state(:draft).count
            send "published_#{name}_count=", send(name).with_state(:published).count
            send "deleted_#{name}_count=",   send(name).with_state(:deleted).count
          end
        end

        save
      end

    end    
  end

  module Comment
    extend ActiveSupport::Concern

    included do
      # Nested Set
      attr_accessible :parent_id
      acts_as_nested_set scope: [:commentable_type, :commentable_id]

      # TheSortableTree
      include TheSortableTree::Scopes

      attr_accessible :user, :title, :contacts, :raw_content, :view_token, :state
      attr_accessible :ip, :referer, :user_agent, :comment_time

      # validates :title, presence: true
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

        after_transition any => :deleted do |comment|
          children = comment.children
          children.each{ |c| c.to_deleted }

          unless children.blank?
            @owner.recalculate_comments_counters
            @holder.recalculate_comments_counters
            @commentable.recalculate_comments_counters
          end
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

  module BlackIp
    extend ActiveSupport::Concern
    
    included do
      attr_accessible :ip

      validates :ip, presence:   true
      validates :ip, uniqueness: true
    end
  end

  module BlackUserAgent
    extend ActiveSupport::Concern

    included do
      attr_accessible :user_agent

      validates :user_agent, presence:   true
      validates :user_agent, uniqueness: true
    end
  end
end