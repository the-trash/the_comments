class TheCommentsSubscriptions < ActiveRecord::Migration
  def change
    change_table :comment_subscriptions do |t|
      t.integer :user_id
      t.integer :comment_id

      t.string :email, default: ''
      t.string :state, default: :active
    end
  end
end
