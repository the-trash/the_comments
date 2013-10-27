class CreateBlackLists < ActiveRecord::Migration
  def change
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
  end
end