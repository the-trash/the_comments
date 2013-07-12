module TheCommentsUser
  extend ActiveSupport::Concern

  included do
    has_many :comments
    has_many :comcoms, class_name: :Comment, foreign_key: :holder_id

    # has_many :posted_comments, class_name: :Comment, foreign_key: :user_id
  end

  def my_comments
    comments.with_state([:draft,:published])
  end

  def recalculate_my_comments_counter!
    self.my_comments_count = my_comments.count
    save
  end

  def recalculate_comcoms_counters!
    self.draft_comcoms_count     = comcoms.with_state(:draft).count
    self.published_comcoms_count = comcoms.with_state(:published).count
    self.deleted_comcoms_count   = comcoms.with_state(:deleted).count
    save
  end

  def comments_sum
    published_comments_count + draft_comments_count
  end

  def comcoms_sum
    published_comcoms_count + draft_comcoms_count
  end
end