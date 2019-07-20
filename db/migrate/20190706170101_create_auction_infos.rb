class CreateAuctionInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :auction_infos do |t|
      t.bigint :bid
      t.string :time_left

      t.belongs_to :auction
      t.timestamps
    end
  end
end
