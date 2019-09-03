namespace :auctions do
  task :fetch, [:region, :client_id, :client_secret] => :environment do |task, args|
    Dir.mktmpdir do |wdir|
      access_token = app_auth(args[:region], args[:client_id], args[:client_secret])
      realms = Realm.where(region: args[:region])

      csv_file = "#{wdir}/records.csv"
      File.open(csv_file, "wb") do |csv|
        csv.puts([:auc, :realm_id, :item, :owner, :region, :owner_realm, :quantity, :buyout, :bid, :time_left, :created_at, :updated_at].join(","))
      end

      # On récupère juste les URL des fichiers d'auctions et on construit un array de la forme [[url, nom du fichier qu'on veut], ...]
      # On met la region et l'id du realm dans le nom du fichier pour que ca puisse être récupéré par le script de conversation de JSON en CSV
      # c'est pas super propre de faire passer de l'information en utilisant un nom de fichier, mais j'ai pas d'autres idées
      auction_urls = realms.map do |realm|
        begin
          print "\rgetting auctions file url for ".ljust(60) + "#{realm.region}/#{realm.name}".ljust(60)
          response = RestClient.get "https://#{realm.region}.api.blizzard.com/wow/auction/data/#{realm.slug}?locale=en_GB&access_token=#{access_token}"
          [ JSON.parse(response.body)['files'][0]['url'], "auctions-#{realm.region}-#{realm.id}.json" ]
        rescue => error
          # En cas de problème on attend une seconde et on retry
          puts error
          sleep 1
          retry
        end
      end
      puts

      # On crée un fichier qu'on passera à aria2, parce qu'il s'en occupera mieux que nous, le format est un peu bizarre
      auction_urls_file = "#{wdir}/urls.txt"

      # On télecharge tout avec aria2
      Thread.new do
        loop do
          File.open(auction_urls_file, "wb") do |f|
            f.write auction_urls.map { |url, output| "#{url}\n\tout=#{output}" }.join("\n")
          end

          # l'option -j permet de mettre une limite haute aux nombre de téléchargement simultané, ca peut valoir le coup de tester d'autres valeurs
          system("aria2c -q -j 32 -m 0 -d #{wdir} --on-download-complete #{Rails.root}/bin/convert_auctions_json_to_csv.rb -i #{auction_urls_file}")

          if $? != 0 # Si le programme s'est fini avec une erreur on fait le compte des fichiers qui n'ont pas été dl et on les redemandes, sinon on break
            auction_urls = auction_urls.select do |auction_url, output|
              !File.exists?("#{wdir}/#{output}")
            end
          else
            break
          end
        end
      end

      # On attend que tout les CSV soit crée, en pratique ca se fait en parallèle du téléchargement
      loop do
        sleep 1

        csv_files = auction_urls.select do |_, output|
          File.exists?("#{wdir}/#{output.gsub(/json$/, 'csv')}")
        end

        print "\rgenerating auctions CSVs".ljust(60) + "#{csv_files.size}/#{auction_urls.count}".ljust(60)
        break if csv_files.size == auction_urls.size
      end
      puts

      # On supprime les .json
      Dir["#{wdir}/auctions*.json"].each { |f| File.unlink f }

      # on fait un gros fichier CSV à partir de tout les petits fichiers (et on en profite pour supprimer les trucs inutiles, j'ai pas beaucoup de disque)
      Dir["#{wdir}/auctions*.csv"].each.with_index do |auctions_csv, index|
        system("cat #{auctions_csv} >> #{csv_file}")
        File.unlink auctions_csv

        print "\rbundling".ljust(60) + "#{index + 1}/#{auction_urls.count}".ljust(60)
      end
      puts

      # On vide les auctions de cette région et on les remplace entièrement par les nouvelles
      puts "copying to database..."
      Auction.transaction do
        Auction.where(region: args[:region]).delete_all
        Auction.copy_from csv_file
      end
    end
  end
end
