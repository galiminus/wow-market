$Regions = ["eu", "us", "kr", "tw"]

$Locales = ["en_GB", "de_DE", "es_ES", "fr_FR", "it_IT", "pl_PL", "pt_PT", "ru_RU", "en_US", "pt_BR", "es_MX", "ko_KR", "zh_TW"]

def auth(region, client_id, client_secret)  
  begin
    response = RestClient.post "https://#{client_id}:#{client_secret}@#{region}.battle.net/oauth/token", :grant_type => 'client_credentials'
    json = JSON.parse(response.body)
    return json["access_token"]
  rescue RestClient::Unauthorized => e
    json = JSON.parse(e.http_body)
    puts "error: #{json["error"]}: #{json["error_description"]}"
    return ""
  rescue => e
    puts "error: #{e.class}: #{e.message}"
    return ""
  end  
end

def fetch_item_name(region, item_id, locale, access_token)
  response = RestClient.get "https://#{region}.api.blizzard.com/data/wow/item/#{item_id}", {params: {:namespace => "static-#{region}", :locale => locale, :access_token => access_token}}
  json = JSON.parse(response)
  return json["name"]
end

namespace :items do
  task :fetch, [:region, :client_id, :client_secret] => :environment do |task, args|
    if !$Regions.include?(args[:region])
      puts "error: unknown region: #{args[:region]}"
      exit 1
    end
    
    print "getting access token... "
    access_token = auth(args[:region], args[:client_id], args[:client_secret])
    if access_token.empty?
      exit 2
    end
    puts "done"

    $Locales.each do |locale|
      puts "#{locale}: #{fetch_item_name(args[:region], 19019, locale, access_token)}"
    end
  end
end
