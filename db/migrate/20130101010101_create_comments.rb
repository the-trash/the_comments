# null: false => de-facto db-level validation
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      # relations
      t.integer :user_id
      t.integer :owner_id
      
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
      # owner of comments
      t.integer :created_comments_count, default: 0

      # has comments on related objects
      t.integer :approved_comments_count, default: 0
      t.integer :not_approved_comments_count,   default: 0
    end

    # [users, :pages, :posts].each do |table_name|
    #   change_table table_name do |t|
    #     t.integer :comments_count, default: 0
    #   end
    # end
  end

end