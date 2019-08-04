require "./lib/tasks/common.rb"

# ------------------------------------------------------------------------------

def fetch_item_name(region, item_id, locale, access_token)
  begin
    response = RestClient.get "https://#{region}.api.blizzard.com/data/wow/item/#{item_id}", {params: {:namespace => "static-#{region}", :locale => locale, :access_token => access_token}}
    json = JSON.parse(response)
    return json["name"]
  rescue RestClient::NotFound => e
    return "not found"
  rescue => e
    return "error: #{e.message}"
  end
end

# ------------------------------------------------------------------------------

def fetch_item_media(region, item_id, access_token)
  begin
    response = RestClient.get "https://#{region}.api.blizzard.com/data/wow/media/item/#{item_id}", {params: {:namespace => "static-#{region}", :locale => "en_GB", :access_token => access_token}}
    json = JSON.parse(response)
    if json["assets"].size > 0
      return json["assets"][0]["value"]
    else
      return "no asset"
    end
  rescue RestClient::NotFound => e
    return "not found"
  rescue => e
    return "error: #{e.message}"
  end
end

# ------------------------------------------------------------------------------

namespace :items do
  task :fetch, [:region, :client_id, :client_secret] => :environment do |task, args|
    access_token = app_auth(args[:region], args[:client_id], args[:client_secret])

    (0..60000).each do |item_id|
      items_infos = []
      puts "#{item_id}"
      name_en = fetch_item_name(args[:region], item_id, "en_GB", access_token)
      if (name_en == "not found")
        puts "\tNot found, skipping item"
        next
      end
      print "\tFetching item media url: "
      media = fetch_item_media(args[:region], item_id, access_token)
      items_infos << {locale: "en_GB", name: name_en, item_id: item_id, media: media}
      puts media
      puts "\tFetching item name (en_GB): #{name_en}"
      $Locales.each do |locale|
        print "\tFetching item name (#{locale}): "
        name = fetch_item_name(args[:region], item_id, locale, access_token)
        items_infos << {locale: locale, name: name, item_id: item_id, media: media}
        puts "#{name}"
      end

      items_infos.each do |item_infos|
        Item.find_or_create_by(item_id: item_infos[:item_id], locale: item_infos[:locale]) do |item_record|
          item_record.item_id = item_infos[:item_id]
          item_record.name = item_infos[:name]
          item_record.locale = item_infos[:locale]
          item_record.media = item_infos[:media]
        end
      end
    end
    
  end
end
