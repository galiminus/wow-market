namespace :auctions_old do
  task :fetch, [:region, :client_id, :client_secret] => :environment do |task, args|
    access_token = app_auth(args[:region], args[:client_id], args[:client_secret])
    
    Realm.all.each do |realm|
      puts "#{realm.region}/#{realm.name}"
      print "\tGetting auctions file url... "
      response = RestClient.get "https://#{realm.region}.api.blizzard.com/wow/auction/data/#{realm.slug}?locale=en_GB&access_token=#{access_token}"
      puts "done"
      url = JSON.parse(response.body)['files'][0]['url']

      print "\tGetting auctions... "
      response = RestClient.get url
      puts "done"
      
      puts "\tStoring #{JSON.parse(response.body)['auctions'].size} auctions... "
      i = 0

      auctions_by_auc = Auction.where(owner_realm: realm.name).group_by(&:auc)
      auctions = JSON.parse(response.body)['auctions']

      auction_infos_attributes = []
      auction_ids = Auction.bulk_insert(return_primary_keys: true, update_duplicates: true) do |auction_worker|
        auctions[0..1000].each do |auction|
          print "\r#{i}/#{auctions.size}"

          auction_record =
            if (auction_records = auctions_by_auc[auction['auc']])
              auction_records.first
            else
              Auction.new(auc: auction['auc']).tap do |auction_record|
                auction_record.item = auction['item']
                auction_record.owner = auction['owner']
                auction_record.region = realm.region
                auction_record.owner_realm = auction['ownerRealm']
                auction_record.quantity = auction['quantity']
                auction_record.buyout = auction['buyout']
                auction_record.created_at = Time.now
                auction_record.updated_at = auction_record.created_at
              end
            end
          auction_infos_attributes.push({
                               bid: auction['bid'],
                               time_left: auction['timeLeft'],
                             })
          i = i + 1

          auction_worker.add(auction_record.attributes)
        end
        puts
      end

      byebug
      AuctionInfo.bulk_insert do |worker|
        auction_infos_attributes.each.with_index do |auction_info_attributes, index|
          worker.add(auction_info_attributes.merge(auction_id: auction_ids[index]))
        end
      end
    end
  end
end
