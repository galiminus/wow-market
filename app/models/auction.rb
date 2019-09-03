class Auction < ApplicationRecord
  self.primary_key = :auc, :realm_id

  acts_as_copy_target

  # has_many :auction_infos, dependent: :destroy

  # def as_json(options = {})
  #   super.merge({
  #     auction_infos: auction_infos.as_json
  #   })
  # end
end
