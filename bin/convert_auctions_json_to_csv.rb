#!/usr/bin/env ruby

require 'json'

# require File.expand_path('../../config/environment', __FILE__)

auctions_file_path = ARGV[2]
output_file = auctions_file_path.gsub(/json$/, 'csv.temp')
_, realm_region, realm_id = File.basename(auctions_file_path).gsub('.json', '').split("-")
created_at = Time.now

File.open auctions_file_path do |auctions_file|
  auctions = JSON.load(auctions_file)['auctions']

  File.open(output_file, "wb+") do |output_file|
    auctions.each do |auction|
      output_file.puts [
        auction['auc'],
        realm_id.to_i,
        auction['item'],
        auction['owner'],
        realm_region,
        auction['ownerRealm'],
        auction['quantity'],
        auction['buyout'],
        auction['bid'],
        auction['timeLeft'],
        created_at,
        created_at
      ].map { |value| value.kind_of?(Numeric) ? value : "\"#{value.to_s.gsub('"', '""')}\"" }.join(",")
    end
  end
end

File.rename output_file, output_file.gsub(".temp", "")


