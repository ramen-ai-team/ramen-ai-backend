namespace :shops do
  desc "既存shopのlatitude/longitudeをPlaces APIから取得して埋める"
  task backfill_coordinates: :environment do
    shops = Shop.where(latitude: nil).or(Shop.where(longitude: nil))
    puts "対象shop数: #{shops.count}"

    success = 0
    failed = 0

    shops.each do |shop|
      place_id = GoogleMaps::PlaceIdExtractor.extract(shop.google_map_url)
      if place_id.nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): place_id取得失敗"
        failed += 1
        next
      end

      details = GoogleMaps::PlacesClient.fetch_place_details(place_id)
      puts "  details: #{details.inspect}"
      if details.nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): Places API失敗 (place_id=#{place_id})"
        failed += 1
        next
      end
      if details[:latitude].nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): geometryなし (place_id=#{place_id})"
        failed += 1
        next
      end

      shop.update!(latitude: details[:latitude], longitude: details[:longitude])
      puts "[OK] #{shop.name} (id=#{shop.id}): #{details[:latitude]}, #{details[:longitude]}"
      success += 1

      sleep 0.2
    end

    puts "\n完了: 成功=#{success}, スキップ=#{failed}"
  end
end
