namespace :auctions do
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
      
      auctions = JSON.parse(response.body)['auctions']

      auctions_by_auc = Auction.where(owner_realm: realm.name).group_by(&:auc)

      existing_auctions_records = {}
      existing_auctions = []
      new_auctions = []
      i = 0
      auctions.each do |auction|
        print "\r\tFinding existing auctions: #{i}/#{auctions.size}"
        if auctions_by_auc.include? auction['auc']
          existing_auctions_records[auction['auc']] = Auction.find_by auc: auction['auc']
          existing_auctions << auction
        else
          new_auctions << auction
        end
        i = i + 1
      end
      puts
      
      Auction.bulk_insert(set_size: 10000) do |auction_worker|

        i = 0
        existing_auctions.each do |auction|
          print "\r\tUpdating existing auctions: #{i}/#{existing_auctions.size}"
          existing_auction_record = existing_auctions_records[auction['auc']]
          existing_auction_record['bid'] = auction['bid']
          existing_auction_record['time_left'] = auction['timeLeft']
          auction_worker.add(existing_auction_record.attributes)
          i = i + 1
        end

        if !existing_auctions.empty?
          puts
        end
        
        i = 0
        new_auctions.each do |auction|
          print "\r\tCreating new auctions: #{i}/#{new_auctions.size}"
          auction_record = Auction.new(auc: auction['auc']).tap do |auction_record|
            auction_record.item = auction['item']
            auction_record.owner = auction['owner']
            auction_record.region = realm.region
            auction_record.owner_realm = auction['ownerRealm']
            auction_record.quantity = auction['quantity']
            auction_record.buyout = auction['buyout']
            auction_record.bid = auction['bid']
            auction_record.time_left = auction['timeLeft']
            auction_record.created_at = Time.now
            auction_record.updated_at = auction_record.created_at
          end
          auction_worker.add(auction_record.attributes)
          i = i + 1
        end
      end
      puts
    end
  end
end
