module TheCommentsUser
  extend ActiveSupport::Concern
  
  included do
    has_many :comcoms, class_name: :Comment, foreign_key: :holder_id
  end

  def my_comments; Comment.where(user: self); end

  def recalculate_my_comments_counter!
    update!(my_comments_count: my_comments.active.count)
  end

  def recalculate_comcoms_counters!
    update_attributes!({
      draft_comcoms_count:     comcoms.with_state(:draft).count,
      published_comcoms_count: comcoms.with_state(:published).count,
      deleted_comcoms_count:   comcoms.with_state(:deleted).count
    })
  end

  def update_comcoms_spam_counter
    update!(spam_comcoms_count: comcoms.where(spam: true).count)
  end

  def comments_sum
    published_comments_count + draft_comments_count
  end

  def comcoms_sum
    published_comcoms_count + draft_comcoms_count
  end
end