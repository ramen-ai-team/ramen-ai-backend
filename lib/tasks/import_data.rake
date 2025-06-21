require "csv"
require "open-uri"

namespace :data do
  desc "Import data from CSV"
  task import: :environment do
    csv_text = File.read(Rails.root.join("csv.csv"))
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")

    csv.each do |row|
      shop_name = row["店舗名"]
      menu_name = row["メニュー名"]
      genre_name = row["ジャンル"]
      noodle_name = row["麺"]
      soup_name = row["スープ"]
      image_url = row["image"]

      next if shop_name.blank? || menu_name.blank? || genre_name.blank? || noodle_name.blank? || soup_name.blank?
      puts "Processing: #{shop_name} - #{menu_name} - #{genre_name} - #{noodle_name} - #{soup_name}"

      # 店舗の作成または検索
      shop = Shop.find_or_create_by(name: shop_name)

      # ジャンルの作成または検索
      genre = Genre.find_or_create_by(name: genre_name)

      # 麺の作成または検索
      noodle = Noodle.find_or_create_by(name: noodle_name)

      # スープの作成または検索
      soup = Soup.find_or_create_by(name: soup_name)

      # メニューの作成
      menu = Menu.create!(name: menu_name, shop_id: shop.id)

      menu.genre = genre
      menu.noodle = noodle
      menu.soup = soup

      # 画像のダウンロードとActive Storageへの保存
      begin
        if image_url.present?
          uri = URI.parse(image_url)
          id = Hash[URI::decode_www_form(uri.query)]["id"]
          url = "https://drive.google.com/uc?id=#{id}"

          downloaded_image = URI.open(url)
          menu.image.attach(io: downloaded_image, filename: File.basename(url))
        end
      rescue OpenURI::HTTPError => e
        puts "Error downloading image: #{image_url} - #{e.message}"
      end
    rescue StandardError => e
      puts "Error processing row: #{row.inspect} - #{e.message}"
    end

    puts "Data import completed!"
  end
end
