def generate_name(number)
  charset = Array('A'..'Z') + Array('a'..'z')
  Array.new(number) { charset.sample }.join
end

namespace :tests do
  task :group => :environment do
    # pp Auction.select(:region, :owner_realm).group(:region, :owner_realm)
    # pp Auction.select(:owner_realm, :id).group(:owner_realm).find_by(region: "eu")
    pp Auction.select(:owner_realm, :region).group(:owner_realm).where(region: "eu")
  end

  task :gen_auctions_1 => :environment do
    regions = ["eu", "us", "kr", "tw"]

    realms = []
    (1..40).each do
      realms << generate_name(10)
    end

    item_ids = []
    (1..200).each do
      item_ids << rand(0..60000)
    end

    owners = []
    (1..100).each do
      owners << generate_name(7)
    end

    (1..1000).each do |i|
      print "\r#{i}/1000"
      auction_record = Auction.create({
                       auc: rand(0..1000),
                       item: item_ids.sample,
                       owner: owners.sample,
                       region: regions.sample,
                       owner_realm: realms.sample,
                       quantity: rand(1..200),
                       buyout: rand(1..1000000000000),
                       bid: 0,
                       time_left: "VERY_LONG",
                     })
    end
    puts
    
  end

  task :gen_auctions_2 => :environment do
    realms = {}
    Realm.all.each do |record|
      if !realms[record.region]
        realms[record.region] = []
      end
      realms[record.region] << record.name
    end

    owners = []
    (1..100).each do
      owners << generate_name(7)
    end

    regions = ["eu", "us", "kr", "tw"]

    (1..1000).each do |i|
      print "\r#{i}/1000"
      region = regions.sample
      auction_record = Auction.create({
                       auc: rand(0..1000),
                       item: Item.offset(rand(Item.count)).first,
                       owner: owners.sample,
                       region: region,
                       owner_realm: realms[region].sample,
                       quantity: rand(1..200),
                       buyout: rand(1..1000000000000),
                       bid: 0,
                       time_left: "VERY_LONG",
                     })
    end
    puts
    
  end
end
