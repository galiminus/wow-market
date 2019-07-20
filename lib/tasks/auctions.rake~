namespace :auctions do
  task :fetch => :environment do
    #    Parallel.map(['hyjal', 'ysondre'], in_processes: 8) do |server|
    ['hyjal', 'ysondre'].each do |server|
      response = RestClient.get "https://us.api.blizzard.com/wow/auction/data/#{server}?locale=en_US&access_token=USTceXQuP9IA4IeRiKDcqLA7ogu1hwhDVQ"
      url = JSON.parse(response.body)['files'][0]['url']

      response = RestClient.get url

      JSON.parse(response.body)['auctions'].each do |auction|
        puts auction['auc']
        auction_record = Auction.find_or_create_by(auc: auction['auc']) do |auction_record|
          auction_record.item = auction['item']
          auction_record.owner = auction['owner']
          auction_record.owner_realm = auction['owner_realm']
          auction_record.quantity = auction['quantity']
          auction_record.buyout = auction['buyout']
        end

        AuctionInfo.create({
                             auction: auction_record,
                             bid: auction['bid'],
                             time_left: auction['timeLeft'],
                           })
      end
    end
  end
end
