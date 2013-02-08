module TheCommentModel
  extend ActiveSupport::Concern

  included do

    def self.anticaptcha_token
      %w[ <!> *?* <<<> ,!, ??! ]
    end

    attr_accessible :user, :title, :contacts,:raw_content

    # relations
    belongs_to :user
    belongs_to :commentable, polymorphic: true

    after_create :update_user_comments_counters

    # STATE MACHINE
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
      after_transition [:not_approved, :deleted] => :approved do |comment|
        object = comment.commentable
        object.increment!(:comments_count)
        owner = object.is_a?(User) ? object : object.user
        owner.increment!(:approved_comments_count)
      end

      after_transition :approved => [:not_approved, :deleted] do |comment|
        object = comment.commentable
        object.decrement!(:comments_count)
        owner = object.is_a?(User) ? object : object.user
        owner.decrement!(:approved_comments_count)
      end
    end

    private

    def update_user_comments_counters
      user.increment!(:created_comments_count) if user
      object = self.commentable
      owner  = object.is_a?(User) ? object : object.user
      owner.increment!(:not_approved_comments_count)
    end

  end

end