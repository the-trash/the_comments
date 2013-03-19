module TheCommentsUser
  extend ActiveSupport::Concern

  included do
    has_many :comments
    has_many :comcoms, class_name: :Comment, foreign_key: :holder_id
  end

  def recalculate_comments_counters!
    [:comments, :comcoms].each do |name|
      send "draft_#{name}_count=",     send(name).with_state(:draft).count
      send "published_#{name}_count=", send(name).with_state(:published).count
      send "deleted_#{name}_count=",   send(name).with_state(:deleted).count
    end
    save
  end

  def comments_sum
    published_comments_count + draft_comments_count
  end

  def comcoms_sum
    published_comcoms_count + draft_comcoms_count
  end
end