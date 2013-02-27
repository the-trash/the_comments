module TheCommentsStates
  extend ActiveSupport::Concern

  included do
    # :draft | :published | :deleted
    state_machine :state, :initial => :draft do

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

        @holder.try :increment!, :"#{to}_comcoms_count"
        @holder.try :decrement!, :"#{from}_comcoms_count"

        [@owner, @commentable].each do |obj|
          obj.try :increment!, "#{to}_comments_count"
          obj.try :decrement!, "#{from}_comments_count"
        end
      end

      # to deleted (cascade like query)
      after_transition [:draft, :published] => :deleted do |comment|
        ids = comment.self_and_descendants.map(&:id)
        comment.class.where(id: ids).update_all(state: :deleted)
        [@holder, @owner, @commentable].each{|o| o.try :recalculate_comments_counters }
      end

      # from deleted
      after_transition :deleted => [:draft, :published] do |comment, transition|
        to = transition.to_name

        @holder.try :decrement!, :deleted_comcoms_count
        @holder.try :increment!, "#{to}_comcoms_count"

        [@owner, @commentable].each do |obj|
          obj.try :decrement!, :deleted_comments_count
          obj.try :increment!, "#{to}_comments_count"
        end
      end
    end
  end
end