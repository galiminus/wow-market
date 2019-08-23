class AuctionsController < ApplicationController
  include CommonConcern
  
  def index
    # byebug
    # @auctions = Auction.includes(:auction_infos).all
    
    # render json: @auctions
    @locales = get_locales
    @realms = get_realms

    if !params[:language].blank? && !params[:region].blank? && !params[:realm].blank?
      if params[:id].blank?
        @id = 0
      else
        @id = params[:id].to_i
        if @id < 0
          @id = 0
        end
      end
      record = Auction.select(:id, :item, :owner, :quantity, :buyout)
      @count = record.size
      @auctions = record.order(id: :desc).limit(20).offset(@id)
    end
    
    render "index"
  end
end
