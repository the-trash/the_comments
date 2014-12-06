# This migration comes from the_comments_engine (originally 20130101010102)
class TheCommentsCreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      # relations
      t.integer :user_id
      t.integer :holder_id
      
      # polymorphic, commentable object
      t.integer :commentable_id
      t.string  :commentable_type

      # denormalization
      t.string  :commentable_url
      t.string  :commentable_title
      t.string  :commentable_state

      # comment
      t.string :anchor
      
      t.string :title
      t.string :contacts

      t.text :raw_content
      t.text :content

      # moderation token
      t.string :view_token

      # state machine => :draft | :published | :deleted
      t.string :state, default: :draft

      # base user data (BanHammer power)
      t.string  :ip,             default: :undefined
      t.string  :referer,        default: :undefined
      t.string  :user_agent,     default: :undefined
      t.integer :tolerance_time

      # unusable: for future versions
      t.boolean :spam, default: false

      # nested set
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth, default: 0

      t.timestamps
    end
  end
end