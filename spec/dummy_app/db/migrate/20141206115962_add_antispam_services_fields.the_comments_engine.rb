# This migration comes from the_comments_engine (originally 20130101010104)
class TheCommentsAddAntispamServicesFields < ActiveRecord::Migration
  def change
    change_table :comments do |t|
      t.string :akismet_state, default: :default

      t.string :yandex_cleanweb_state, default: :default
      t.string :yandex_cleanweb_id,    default: ''
    end
  end
end
