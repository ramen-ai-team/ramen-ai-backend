require 'rails_helper'

require 'rails_helper'

RSpec.describe Api::V1::MenuWithShopsController, type: :request do
  describe 'GET /api/v1/menu_with_shops/:id' do
    let!(:genre) { create(:genre, name: 'ラーメン') }
    let!(:noodle) { create(:noodle, name: '太麺') }
    let!(:soup) { create(:soup, name: '豚骨') }
    let!(:shop) { create(:shop, name: 'ラーメン屋', address: '東京都新宿区', google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9') }
    let!(:menu) { create(:menu, :with_category, genre:, noodle:, soup:, shop:, name: '特製ラーメン') }

    it 'returns a specific menu' do
      get "/api/v1/menu_with_shops/#{menu.id}"
      expect(response.status).to eq 200
      expect(json).to eq({
        id: menu.id,
        name: '特製ラーメン',
        genre_name: "ラーメン",
        noodle_name: "太麺",
        soup_name: "豚骨",
        image_url: nil,
        shop: {
          id: shop.id,
          name: 'ラーメン屋',
          address: '東京都新宿区',
          google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9'
        }
      })
    end
  end
end
