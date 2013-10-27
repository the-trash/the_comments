# This migration comes from the_comments_engine (originally 20130101010103)
class ChangeCommentable < ActiveRecord::Migration
  def change
    # Uncomment this. Add fields to Commentable Models
    #
    [:users, :posts].each do |table_name|
      change_table table_name do |t|
        t.integer :draft_comments_count,     default: 0
        t.integer :published_comments_count, default: 0
        t.integer :deleted_comments_count,   default: 0
      end
    end
  end
end