# null: false => de-facto db-level validation
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      # relations
      t.integer :user_id
      t.integer :holder_id
      
      # polymorphic, commentable obj
      t.integer :commentable_id
      t.string  :commentable_type

      # comment
      t.string :title
      t.string :contacts

      t.text :raw_content
      t.text :content

      # state machine => :not_approved | :approved | :deleted
      t.string :state, default: :not_approved

      # base user data (BanHammer power)
      t.string :ip
      t.string :referer
      t.string :user_agent

      # nested set
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth, default: 0

      t.timestamps
    end

    # Add fields to User and Commentable Object
    change_table :users do |t|
      # commentable's comments => comcoms (cache)
      # Relation through Comment#holder_id field
      t.integer :total_comcoms_count,    default: 0
      t.integer :approved_comcoms_count, default: 0
      t.integer :new_comcoms_count,      default: 0
      t.integer :del_comcoms_count,      default: 0
    end

    # Uncomment this. Add fields to User model and Commentable models
    #
    # [:users, :posts].each do |table_name|
    #   change_table table_name do |t|
    #     t.integer :total_comments_count,    default: 0
    #     t.integer :approved_comments_count, default: 0
    #     t.integer :new_comments_count,      default: 0
    #     t.integer :del_comments_count,      default: 0
    #   end
    # end
  end

end