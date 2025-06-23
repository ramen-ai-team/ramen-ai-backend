require 'rails_helper'

require 'rails_helper'

RSpec.describe Api::V1::RandomMenusController, type: :request do
  describe 'GET /api/v1/random_menus' do
    let!(:shop) { create(:shop, name: '博多ラーメン店', address: '福岡県博多区', google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9') }
    let!(:menu) { create(:menu, :with_category, name: '博多ラーメン', genre:, noodle:, soup:, shop:) }
    let!(:genre) { create(:genre, name: 'ラーメン') }
    let!(:noodle) { create(:noodle, name: '細麺') }
    let!(:soup) { create(:soup, name: '豚骨スープ') }

    it 'returns all menus' do
      get '/api/v1/random_menus'
      expect(response.status).to eq 200
      expect(json).to match({
        menus: [{
          id: menu.id,
          name: '博多ラーメン',
          genre_name: 'ラーメン',
          noodle_name: '細麺',
          soup_name: '豚骨スープ',
          image_url: be_nil,
          shop: {
            id: shop.id,
            name: '博多ラーメン店',
            address: '福岡県博多区',
            google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9'
          }
        }]
      })
    end
  end
end
