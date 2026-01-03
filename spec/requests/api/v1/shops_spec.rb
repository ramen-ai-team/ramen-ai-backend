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

  describe 'POST /api/v1/shops' do
    let(:user) { create(:user) }
    let(:google_map_url) { 'https://maps.app.goo.gl/dGfTAMwDfw29yLPc7' }
    let(:full_url) { 'https://www.google.com/maps/place/Ramen+Shop/@35.6812,139.7671,17z/data=!3m1!4b1!4m6!3m5!1s0x60188b8e1234abcd:0x1234567890abcdef!8m2!3d35.6812!4d139.7671' }
    let(:place_id) { '0x60188b8e1234abcd:0x1234567890abcdef' }
    let(:api_key) { 'test_api_key' }

    before do
      allow(Rails.application.credentials).to receive(:google_maps_api_key).and_return(api_key)
      stub_request(:get, google_map_url)
        .to_return(status: 301, headers: { 'Location' => full_url })
    end

    context 'with valid Google Maps URL' do
      let(:places_api_response) do
        {
          result: {
            name: 'ラーメン太郎',
            formatted_address: '東京都渋谷区道玄坂1-2-3',
            formatted_phone_number: '03-1234-5678',
            place_id: place_id
          },
          status: 'OK'
        }.to_json
      end

      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 200, body: places_api_response, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a new shop from Google Maps data' do
        expect {
          post '/api/v1/shops', params: { google_map_url: google_map_url }, headers: auth_headers_for(user)
        }.to change(Shop, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to match({
          id: Shop.last.id,
          name: 'ラーメン太郎',
          address: '東京都渋谷区道玄坂1-2-3',
          google_map_url: google_map_url
        })
      end
    end

    context 'with invalid Google Maps URL' do
      it 'returns bad request error' do
        post '/api/v1/shops', params: { google_map_url: 'https://example.com' }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({
          errors: ['Google map url は「https://maps.app.goo.gl/」から始まるGoogle Map URLにしてください']
        })
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/shops', params: { google_map_url: google_map_url }

        expect(response).to have_http_status(:unauthorized)
        expect(json).to eq({
          error: 'Authorization header missing'
        })
      end
    end

    context 'when Places API returns error' do
      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 500, body: '', headers: {})
      end

      it 'returns service unavailable error' do
        post '/api/v1/shops', params: { google_map_url: google_map_url }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:service_unavailable)
        expect(json).to eq({
          errors: ['Google map url から店舗情報を取得できませんでした']
        })
      end
    end
  end
end
