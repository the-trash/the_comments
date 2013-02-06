class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      # relations
      t.integer :user_id
      
      # polymorphic, commentable obj
      t.integer :obj_id
      t.string  :obj_type

      # comment
      t.string :title,    null: false
      t.string :contacts, null: false

      t.text :raw_content, null: false
      t.text :content,     null: false

      # state machine => :not_approved | :approved
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
  end

  def self.down
    drop_table :comments
  end
end