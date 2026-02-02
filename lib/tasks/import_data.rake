require "csv"
require "open-uri"
require "digest"
require "fileutils"

namespace :data do
  desc "Import data from CSV"
  task import: :environment do
    csv_file_path = Rails.root.join("csv.csv")
    hash_file_path = Rails.root.join("tmp", "last_import_hash.txt")

    # CSVファイルのハッシュ値を計算
    csv_text = File.read(csv_file_path)
    current_hash = Digest::MD5.hexdigest(csv_text)

    # 前回のハッシュ値を読み込み
    last_hash = File.exist?(hash_file_path) ? File.read(hash_file_path).strip : nil

    # ハッシュ値が同じ場合はスキップ
    if current_hash == last_hash
      puts "CSV file has not changed. Skipping data import."
      next
    end

    puts "CSV file has changed. Starting data import..."

    # データ削除
    Shop.destroy_all
    Genre.destroy_all
    Noodle.destroy_all
    Soup.destroy_all

    # インポート
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")

    csv.each do |row|
      shop_name = row["店舗名"]
      menu_name = row["メニュー名"]
      genre_name = row["ジャンル"]
      noodle_name = row["麺"]
      soup_name = row["スープ"]
      image_url = row["画像"]
      address = row["住所"]
      google_map_url = row["Google Map URL"]

      next if shop_name.blank? || menu_name.blank? || genre_name.blank? || noodle_name.blank? || soup_name.blank? || image_url.blank? || address.blank? || google_map_url.blank?
      puts "Processing: #{shop_name} - #{menu_name} - #{genre_name} - #{noodle_name} - #{soup_name} - #{image_url} - #{address} - #{google_map_url}"

      # 店舗の作成または検索
      shop = Shop.find_or_create_by(google_map_url: google_map_url) do |s|
        s.address = address
        s.name = shop_name
      end

      # ジャンルの作成または検索
      genre = Genre.find_or_create_by(name: genre_name)

      # 麺の作成または検索
      noodle = Noodle.find_or_create_by(name: noodle_name)

      # スープの作成または検索
      soup = Soup.find_or_create_by(name: soup_name)

      # メニューの作成（まだ保存しない）
      menu = Menu.new(name: menu_name, shop_id: shop.id)

      menu.genre = genre
      menu.noodle = noodle
      menu.soup = soup

      # 画像のダウンロードとActive Storageへの保存
      begin
        if image_url.present?
          uri = URI.parse(image_url)
          id = Hash[URI.decode_www_form(uri.query)]["id"]
          url = "https://drive.google.com/uc?id=#{id}"

          downloaded_image = URI.open(url)
          menu.image.attach(io: downloaded_image, filename: File.basename(url))
        end
      rescue OpenURI::HTTPError => e
        puts "Error downloading image: #{image_url} - #{e.message}"
      end

      # 画像添付後に保存
      menu.save!
    rescue StandardError => e
      puts "Error processing row: #{row.inspect} - #{e.message}"
    end

    # ハッシュ値を保存
    FileUtils.mkdir_p(File.dirname(hash_file_path))
    File.write(hash_file_path, current_hash)

    puts "Data import completed!"
  end
end
