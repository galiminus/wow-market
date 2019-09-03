class AddIndexToAuctionsRegions < ActiveRecord::Migration[5.2]
  def change
    add_index :auctions, :region
  end
end
