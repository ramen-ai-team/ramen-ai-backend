namespace :menu_reports do
  desc "menu_genre/noodle/soup のデータを menu_reports レコードにコピーする (user_id=1)"
  task migrate: :environment do
    user = User.find(1)

    menus = Menu
      .joins(:menu_genre, :menu_noodle, :menu_soup)
      .includes(:menu_genre, :menu_noodle, :menu_soup)

    puts "対象メニュー数: #{menus.count}"

    created = 0
    skipped = 0

    menus.each do |menu|
      if MenuReport.exists?(user: user, menu: menu)
        skipped += 1
        next
      end

      MenuReport.create!(
        user: user,
        menu: menu,
        genre_id: menu.menu_genre.genre_id,
        noodle_id: menu.menu_noodle.noodle_id,
        soup_id: menu.menu_soup.soup_id
      )
      created += 1
    end

    puts "作成: #{created}, スキップ（既存）: #{skipped}"
  end
end
