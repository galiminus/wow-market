class RemoveUniquenessOnAucIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :auctions, :auc
    add_index :auctions, :auc
  end
end
