require 'rails_helper'

require 'rails_helper'

RSpec.describe Api::V1::ShopsController, type: :request do
  describe 'GET /api/v1/shops' do
    let!(:shop) { create(:shop, name: '九州 筑豊ラーメン山小屋', address: '佐賀県嬉野市嬉野町大字下宿甲４００２−４', google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9') }

    it 'returns all shops' do
      get '/api/v1/shops'
      expect(response.status).to eq 200
      expect(json).to eq({
        shops: [{
          id: shop.id,
          name: '九州 筑豊ラーメン山小屋',
          address: '佐賀県嬉野市嬉野町大字下宿甲４００２−４',
          google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9'
        }]
      })
    end
  end

  describe 'GET /api/v1/shops/:id' do
    let!(:shop) { create(:shop, name: '九州 筑豊ラーメン山小屋', address: '佐賀県嬉野市嬉野町大字下宿甲４００２−４', google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9') }

    it 'returns a specific shop' do
      get "/api/v1/shops/#{shop.id}"
      expect(response.status).to eq 200
      expect(json).to eq({
        id: shop.id,
        name: '九州 筑豊ラーメン山小屋',
        address: '佐賀県嬉野市嬉野町大字下宿甲４００２−４',
        google_map_url: 'https://maps.app.goo.gl/BvuQTxGsmKLJ68yL9'
      })
    end
  end
end
