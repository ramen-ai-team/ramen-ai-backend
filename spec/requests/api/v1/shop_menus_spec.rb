require 'rails_helper'

RSpec.describe 'GET /api/v1/shops/{shop_id}/menus', type: :request do
  let(:shop) { create(:shop) }

  let(:menu_json) do |menu|
    {
      id: menu.id,
      name: menu.name,
      genre_name: nil,
      noodle_name: nil,
      soup_name: nil,
      image_url: a_string_starting_with('http'),
      shop: {
        id: shop.id,
        name: shop.name,
        address: shop.address,
        google_map_url: shop.google_map_url
      }
    }
  end

  it '店舗のメニュー一覧を返す' do
    menu1 = create(:menu, shop: shop, name: '醤油ラーメン')
    menu2 = create(:menu, shop: shop, name: '味噌ラーメン')

    get "/api/v1/shops/#{shop.id}/menus"

    expect(response).to have_http_status(:ok)
    expect(json).to match({
      menus: contain_exactly(
        {
          id: menu1.id,
          name: '醤油ラーメン',
          genre_name: nil,
          noodle_name: nil,
          soup_name: nil,
          image_url: a_string_starting_with('http'),
          shop: {
            id: shop.id,
            name: shop.name,
            address: shop.address,
            google_map_url: shop.google_map_url
          }
        },
        {
          id: menu2.id,
          name: '味噌ラーメン',
          genre_name: nil,
          noodle_name: nil,
          soup_name: nil,
          image_url: a_string_starting_with('http'),
          shop: {
            id: shop.id,
            name: shop.name,
            address: shop.address,
            google_map_url: shop.google_map_url
          }
        }
      )
    })
  end

  it '他の店舗のメニューは含まない' do
    other_shop = create(:shop)
    create(:menu, shop: other_shop)
    menu = create(:menu, shop: shop)

    get "/api/v1/shops/#{shop.id}/menus"

    expect(json[:menus].map { |m| m[:id] }).to eq([menu.id])
  end

  it '存在しないshop_idは404を返す' do
    get '/api/v1/shops/0/menus'

    expect(response).to have_http_status(:not_found)
  end
end
