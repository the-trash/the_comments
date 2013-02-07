module TheCommentModel
  extend ActiveSupport::Concern

  included do

    def self.anticaptcha_token
      %w[ <!> *?* <<<> ,!, ??! ]
    end

    # relations
    belongs_to :user
    belongs_to :commentable, polymorphic: true

    after_create :update_new_comments_counter

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

        if object.is_a? User
          object.increment!(:total_comments_count)
        else
          object.user.increment!(:total_comments_count)
        end
      end

      after_transition :approved => [:not_approved, :deleted] do |comment|
        object = comment.commentable
        object.decrement!(:comments_count)

        if object.is_a? User
          object.decrement!(:total_comments_count)
        else
          object.user.decrement!(:total_comments_count)
        end
      end
    end

    private

    def update_new_comments_counter
      object = comment.commentable
      if object.is_a? User
        object.increment!(:new_comments_count)
      else
        object.user.increment!(:new_comments_count)
      end
    end

  end

end