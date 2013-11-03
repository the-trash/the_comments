module TheComments
  module CommentStates
    extend ActiveSupport::Concern

    included do
      # :draft | :published | :deleted
      state_machine :state, :initial => TheComments.config.default_state do

        # events
        event :to_draft do
          transition all - :draft => :draft
        end

        event :to_published do
          transition all - :published => :published
        end

        event :to_deleted do
          transition any - :deleted => :deleted
        end

        # transition callbacks
        after_transition any => any do |comment|
          @comment     = comment
          @owner       = comment.user
          @holder      = comment.holder
          @commentable = comment.commentable
        end

        # between draft and published
        after_transition [:draft, :published] => [:draft, :published] do |comment, transition|
          from = transition.from_name
          to   = transition.to_name

          if @holder
            @holder.send :try, :define_denormalize_flags
            @holder.increment! "#{to}_comcoms_count"
            @holder.decrement! "#{from}_comcoms_count"
          end

          if @commentable
            @commentable.send       :define_denormalize_flags
            @commentable.increment! "#{to}_comments_count"
            @commentable.decrement! "#{from}_comments_count"
          end
        end

        # to deleted (cascade like query)
        after_transition [:draft, :published] => :deleted do |comment|
          ids = comment.self_and_descendants.map(&:id)
          ::Comment.where(id: ids).update_all(state: :deleted)

          @owner.try       :recalculate_my_comments_counter!
          @holder.try      :recalculate_comcoms_counters!
          @commentable.try :recalculate_comments_counters!
        end

        # from deleted
        after_transition :deleted => [:draft, :published] do |comment, transition|
          to = transition.to_name
          comment.mark_as_not_spam

          @owner.try :recalculate_my_comments_counter!

          if @holder
            @holder.send :try, :define_denormalize_flags
            @holder.decrement! :deleted_comcoms_count
            @holder.increment! "#{to}_comcoms_count"
          end

          if @commentable
            @commentable.send       :define_denormalize_flags
            @commentable.decrement! :deleted_comments_count
            @commentable.increment! "#{to}_comments_count"
          end
        end
      end
    end
  end
end