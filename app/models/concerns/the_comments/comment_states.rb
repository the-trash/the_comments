module TheComments
  module CommentStates
    extend ActiveSupport::Concern

    included do
      # :draft | :published | :deleted
      state_machine :state, initial: TheComments.config.default_state do

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

        # between delete, draft and published
        after_transition [ :deleted, :draft, :published ] => [ :draft, :published ] do |comment, transition|
          from = transition.from_name
          to   = transition.to_name

          if from.to_s == 'deleted'
            comment.mark_as_ham
            @owner.try :recalculate_my_comments_counter!
          end

          if @holder
            @holder.update_columns({
              "#{ to }_comcoms_count"   => @holder.send("#{ to }_comcoms_count")   + 1,
              "#{ from }_comcoms_count" => @holder.send("#{ from }_comcoms_count") - 1
            })
          end

          if @commentable
            @commentable.update_columns({
              "#{ to }_comments_count"   => @commentable.send("#{ to }_comments_count")   + 1,
              "#{ from }_comments_count" => @commentable.send("#{ from }_comments_count") - 1
            })
          end
        end

        # to deleted (cascade like query)
        after_transition [ :draft, :published ] => :deleted do |comment|
          ids = comment.self_and_descendants.map(&:id)
          ::Comment.where(id: ids).update_all(state: :deleted)

          @owner.try       :recalculate_my_comments_counter!
          @holder.try      :recalculate_comcoms_counters!
          @commentable.try :recalculate_comments_counters!
        end
      end
    end
  end
end
