class SetAucAsAuctionPrimaryKey < ActiveRecord::Migration[5.2]
  def change
    remove_column :auctions, :id, :bigint, index: true, unique: true
    remove_index :auctions, :auc
    add_index :auctions, :auc, unique: true
    execute "ALTER TABLE auctions ADD PRIMARY KEY (auc);"
  end
end
