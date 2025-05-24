require 'yaml'

master_data = YAML.load_file(Rails.root.join('master_data.yml'))

master_data['genres'].each do |genre_data|
  Genre.find_or_create_by!(name: genre_data['name'])
end

master_data['noodles'].each do |noodle_data|
  Noodle.find_or_create_by!(name: noodle_data['name'])
end

master_data['soups'].each do |soup_data|
  Soup.find_or_create_by!(name: soup_data['name'])
end

master_data['shops'].each do |shop_data|
  Shop.find_or_create_by!(name: shop_data['name'])
end

master_data['menus'].each do |menu_data|
  shop = Shop.find_by!(name: menu_data['shop'])
  genre = Genre.find_by!(name: menu_data['genre'])
  noodle = Noodle.find_by!(name: menu_data['noodle'])
  soup = Soup.find_by!(name: menu_data['soup'])

  Menu.find_or_create_by!(
    name: menu_data['name'],
    shop: shop,
    genre: genre,
    noodle: noodle,
    soup: soup
  )
end
