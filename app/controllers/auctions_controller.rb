class AuctionsController < ApplicationController
  def index
    # byebug
    # @auctions = Auction.includes(:auction_infos).all
    
    # render json: @auctions
    @locales = []
    Realm.select(:locale).group(:locale).each do |record|
      @locales << record.locale
    end
    @realms = {}
    regions_records = Auction.select(:region).group(:region)
    regions_records.each do |region_record|
      realms_record = Auction.select(:owner_realm).group(:owner_realm).where(region: region_record.region).order(:owner_realm)
      @realms[region_record.region] = []
      realms_record.each do |realm_record|
        @realms[region_record.region] << realm_record.owner_realm
      end
    end

    render "index"
  end
end
