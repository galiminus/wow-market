class AddCompositeIdToAuctions < ActiveRecord::Migration[5.2]
  def up
    add_belongs_to :auctions, :realm
    execute "ALTER TABLE auctions DROP CONSTRAINT auctions_pkey;"
    execute "ALTER TABLE auctions ADD PRIMARY KEY (auc, realm_id);"
  end

  def down
    remove_belongs_to :auctions, :realm
    execute "ALTER TABLE auctions ADD PRIMARY KEY (auc);"
  end
end
