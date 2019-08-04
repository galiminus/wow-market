require "./lib/tasks/common.rb"

namespace :realms do
  task :fetch, [:region, :client_id, :client_secret] => :environment do |task, args|
    access_token = app_auth(args[:region], args[:client_id], args[:client_secret])
    
    $Regions.each do |region|
      response = RestClient.get "https://#{region}.api.blizzard.com/wow/realm/status?locale=en_GB&access_token=#{access_token}"
      json = JSON.parse(response)
      json["realms"].each do |realm|
        Realm.create({
                       region: region,
                       name: realm["name"],
                       slug: realm["slug"],
                       battlegroup: realm["battlegroup"],
                       locale: realm["locale"],
                       population: realm["population"],
                     })
      end
    end
  
  end
end
