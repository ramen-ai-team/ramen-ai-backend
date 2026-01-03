require 'rails_helper'

RSpec.describe ShopForm, type: :model do
  describe 'validations' do
    it 'is valid with a valid Google Maps URL' do
      form = ShopForm.new(google_map_url: 'https://maps.app.goo.gl/abc123')
      expect(form).to be_valid
    end

    it 'is invalid without google_map_url' do
      form = ShopForm.new(google_map_url: nil)
      expect(form).not_to be_valid
      expect(form.errors[:google_map_url]).to include("を入力してください")
    end

    it 'is invalid with non-Google Maps URL' do
      form = ShopForm.new(google_map_url: 'https://example.com')
      expect(form).not_to be_valid
      expect(form.errors[:google_map_url]).to include('は「https://maps.app.goo.gl/」から始まるGoogle Map URLにしてください')
    end
  end

  describe '#save' do
    let(:google_map_url) { 'https://maps.app.goo.gl/dGfTAMwDfw29yLPc7' }
    let(:full_url) { 'https://www.google.com/maps/place/Ramen+Shop/@35.6812,139.7671,17z/data=!3m1!4b1!4m6!3m5!1s0x60188b8e1234abcd:0x1234567890abcdef!8m2!3d35.6812!4d139.7671' }
    let(:place_id) { '0x60188b8e1234abcd:0x1234567890abcdef' }
    let(:api_key) { 'test_api_key' }

    before do
      allow(Rails.application.credentials).to receive(:google_maps_api_key).and_return(api_key)
      stub_request(:get, google_map_url)
        .to_return(status: 301, headers: { 'Location' => full_url })
      stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
        .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
        .to_return(status: 200, body: {
          result: {
            name: 'ラーメン太郎',
            formatted_address: '東京都渋谷区道玄坂1-2-3',
            formatted_phone_number: '03-1234-5678',
            place_id: place_id
          },
          status: 'OK'
        }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    context 'with valid Google Maps URL' do
      it 'creates a new shop' do
        form = ShopForm.new(google_map_url: google_map_url)
        expect { form.save }.to change(Shop, :count).by(1)
      end

      it 'returns the created shop' do
        form = ShopForm.new(google_map_url: google_map_url)
        shop = form.save
        expect(shop).to be_a(Shop)
        expect(shop.name).to eq('ラーメン太郎')
        expect(shop.address).to eq('東京都渋谷区道玄坂1-2-3')
        expect(shop.google_map_url).to eq(google_map_url)
      end
    end

    context 'when Place ID cannot be extracted' do
      it 'does not create a shop and returns false' do
        form = ShopForm.new(google_map_url: 'https://maps.app.goo.gl/invalid')
        allow(GoogleMaps::PlaceIdExtractor).to receive(:extract).and_return(nil)

        expect { form.save }.not_to change(Shop, :count)
        expect(form.save).to be false
        expect(form.errors[:google_map_url]).to include('から店舗情報を取得できませんでした')
      end
    end

    context 'when Places API returns error' do
      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 500, body: '', headers: {})
      end

      it 'does not create a shop and returns false' do
        form = ShopForm.new(google_map_url: google_map_url)

        expect { form.save }.not_to change(Shop, :count)
        expect(form.save).to be false
        expect(form.errors[:google_map_url]).to include('から店舗情報を取得できませんでした')
      end
    end
  end
end
