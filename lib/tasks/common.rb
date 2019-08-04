$Regions = ["eu", "us", "kr", "tw"]

$Locales = ["de_DE", "es_ES", "fr_FR", "it_IT", "ru_RU", "pt_BR", "es_MX", "ko_KR", "zh_TW"]
# "en_GB",
# "en_US",
# "pl_PL", "pt_PT",

def blizz_auth(region, client_id, client_secret)  
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

def app_auth(region, client_id, client_secret)
  if !$Regions.include?(region)
      puts "error: unknown region: #{region}"
      exit 1
    end
    
    print "getting access token... "
    access_token = blizz_auth(region, client_id, client_secret)
    if access_token.empty?
      exit 2
    end
    puts "done"
    return access_token
end
