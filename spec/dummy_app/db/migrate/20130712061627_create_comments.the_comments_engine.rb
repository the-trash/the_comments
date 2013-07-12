# This migration comes from the_comments_engine (originally 20130101010101)
# null: false => de-facto db-level validation
class CreateComments < ActiveRecord::Migration
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

    # Black Lists
    create_table :ip_black_lists do |t|
      t.string  :ip
      t.integer :count, default: 0
      t.string  :state, default: :warning
    end

    create_table :user_agent_black_lists do |t|
      t.string  :user_agent
      t.integer :count, default: 0
      t.string  :state, default: :warning
    end

    # Add fields to User Model
    change_table :users do |t|
      # posted_comments.with_state([:draft,:published])
      t.integer :my_comments_count, default: 0

      # commentable's comments => comcoms (cache)
      # Relation through Comment#holder_id field
      t.integer :draft_comcoms_count,     default: 0
      t.integer :published_comcoms_count, default: 0
      t.integer :deleted_comcoms_count,   default: 0

      # unusable: for future versions
      t.integer :spam_comcoms_count,      default: 0
    end

    # Uncomment this. Add fields to Commentable Models
    #
    # [:posts, :blogs, :articles, :pages].each do |table_name|
    #   change_table table_name do |t|
    #     t.integer :draft_comments_count,     default: 0
    #     t.integer :published_comments_count, default: 0
    #     t.integer :deleted_comments_count,   default: 0
    #   end
    # end
  end

end