class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :name,        :null => false
      t.string :title,       :null => false
      t.text   :description, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end