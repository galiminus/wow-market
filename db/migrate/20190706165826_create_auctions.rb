class CreateAuctions < ActiveRecord::Migration[5.2]
  def change
    create_table :auctions do |t|
      t.bigint :auc, index: true
      t.bigint :item
      t.string :owner
      t.string :region
      t.string :owner_realm
      t.integer :quantity
      t.bigint :buyout
      t.bigint :bid
      t.string :time_left
      t.timestamps
    end
  end
end
