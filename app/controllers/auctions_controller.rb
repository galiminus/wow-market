class AuctionsController < ApplicationController
  def index
    @auctions = Auction.includes(:auction_infos).all

    render json: @auctions
  end
end
