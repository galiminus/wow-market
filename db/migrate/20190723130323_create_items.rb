class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.integer :item_id, index: true
      t.string :name
      t.string :locale
      t.string :media
      t.timestamps
    end
  end
end
