namespace :shops do
  desc "既存shopのlatitude/longitudeをPlaces APIから取得して埋める"
  task backfill_coordinates: :environment do
    shops = Shop.where(latitude: nil).or(Shop.where(longitude: nil))
    puts "対象shop数: #{shops.count}"

    success = 0
    failed = 0

    shops.each do |shop|
      search_info = GoogleMaps::PlaceIdExtractor.extract(shop.google_map_url)
      if search_info.nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): search_info取得失敗"
        failed += 1
        next
      end

      details = GoogleMaps::PlacesClient.fetch_place_details(search_info)
      puts "  details: #{details.inspect}"
      if details.nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): Places API失敗 (search_info=#{search_info.inspect})"
        failed += 1
        next
      end
      if details[:latitude].nil?
        puts "[SKIP] #{shop.name} (id=#{shop.id}): 座標なし (search_info=#{search_info.inspect})"
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
