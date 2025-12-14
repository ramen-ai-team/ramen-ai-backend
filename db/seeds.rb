# development環境でのみ実行
unless Rails.env.development?
  puts "Skipping seed data (only runs in development environment)"
  return
end

puts "Creating seed data..."

# ジャンルの作成
puts "Creating genres..."
genres = [
  "醤油",
  "味噌",
  "塩",
  "豚骨",
  "つけ麺",
  "油そば",
  "担々麺"
]
genres.each do |name|
  Genre.find_or_create_by!(name: name)
end

# 麺の種類の作成
puts "Creating noodles..."
noodles = [
  "太麺",
  "細麺",
  "中細麺",
  "平打ち麺",
  "ちぢれ麺",
  "ストレート麺"
]
noodles.each do |name|
  Noodle.find_or_create_by!(name: name)
end

# スープの種類の作成
puts "Creating soups..."
soups = [
  "豚骨",
  "鶏白湯",
  "魚介",
  "魚介豚骨",
  "鶏ガラ",
  "野菜",
  "煮干し"
]
soups.each do |name|
  Soup.find_or_create_by!(name: name)
end

# サンプル店舗の作成
puts "Creating sample shops..."
shops_data = [
  {
    name: "ラーメン一番",
    address: "東京都渋谷区道玄坂1-1-1",
    google_map_url: "https://maps.google.com/?q=sample_shop_001"
  },
  {
    name: "麺屋 山田",
    address: "東京都新宿区新宿3-1-1",
    google_map_url: "https://maps.google.com/?q=sample_shop_002"
  },
  {
    name: "豚骨ラーメン 博多",
    address: "東京都港区六本木1-1-1",
    google_map_url: "https://maps.google.com/?q=sample_shop_003"
  }
]
shops_data.each do |shop_data|
  Shop.find_or_create_by!(google_map_url: shop_data[:google_map_url]) do |shop|
    shop.name = shop_data[:name]
    shop.address = shop_data[:address]
  end
end

# サンプルメニューの作成
puts "Creating sample menus..."

# ダミー画像を生成するヘルパーメソッド
def create_dummy_image
  # 最小限の1x1 PNG画像を生成
  png_data = [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222,
    0, 0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192, 0, 0,
    3, 1, 1, 0, 24, 221, 141, 176, 0, 0, 0, 0, 73, 69, 78, 68,
    174, 66, 96, 130
  ].pack('C*')

  StringIO.new(png_data)
end

shops = Shop.all
shoyu_genre = Genre.find_by(name: "醤油")
miso_genre = Genre.find_by(name: "味噌")
tonkotsu_genre = Genre.find_by(name: "豚骨")

thin_noodle = Noodle.find_by(name: "細麺")
thick_noodle = Noodle.find_by(name: "太麺")
medium_noodle = Noodle.find_by(name: "中細麺")

chicken_soup = Soup.find_by(name: "鶏ガラ")
tonkotsu_soup = Soup.find_by(name: "豚骨")
seafood_soup = Soup.find_by(name: "魚介")

menus_data = [
  {
    shop: shops[0],
    name: "醤油ラーメン",
    genre: shoyu_genre,
    noodle: medium_noodle,
    soup: chicken_soup
  },
  {
    shop: shops[0],
    name: "味噌ラーメン",
    genre: miso_genre,
    noodle: thick_noodle,
    soup: chicken_soup
  },
  {
    shop: shops[1],
    name: "魚介醤油ラーメン",
    genre: shoyu_genre,
    noodle: thin_noodle,
    soup: seafood_soup
  },
  {
    shop: shops[2],
    name: "豚骨ラーメン",
    genre: tonkotsu_genre,
    noodle: thin_noodle,
    soup: tonkotsu_soup
  }
]

menus_data.each do |menu_data|
  menu = Menu.find_or_initialize_by(
    shop: menu_data[:shop],
    name: menu_data[:name]
  )

  unless menu.persisted?
    menu.image.attach(
      io: create_dummy_image,
      filename: "#{menu_data[:name]}.png",
      content_type: "image/png"
    )
    menu.save!

    # 関連を作成
    MenuGenre.find_or_create_by!(menu: menu, genre: menu_data[:genre]) if menu_data[:genre]
    MenuNoodle.find_or_create_by!(menu: menu, noodle: menu_data[:noodle]) if menu_data[:noodle]
    MenuSoup.find_or_create_by!(menu: menu, soup: menu_data[:soup]) if menu_data[:soup]
  end
end

puts "Seed data created successfully!"
puts "  - #{Genre.count} genres"
puts "  - #{Noodle.count} noodles"
puts "  - #{Soup.count} soups"
puts "  - #{Shop.count} shops"
puts "  - #{Menu.count} menus"
