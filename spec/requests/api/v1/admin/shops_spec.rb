require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Shops', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/shops' do
    context 'when admin is authenticated' do
      it 'returns all shops with menus' do
        shop = create(:shop, name: 'Ramen Shop', address: '東京都渋谷区1', google_map_url: 'https://maps.app.goo.gl/abc')
        menu = create(:menu, shop: shop, name: 'Shoyu Ramen')

        get '/api/v1/admin/shops', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(1)
        expect(json.first).to include(
          id: shop.id,
          name: 'Ramen Shop',
          address: '東京都渋谷区1'
        )
        expect(json.first[:menus]).to be_an(Array)
        expect(json.first[:menus].first).to include(id: menu.id, name: 'Shoyu Ramen')
      end

      it 'returns empty array when no shops exist' do
        get '/api/v1/admin/shops', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/shops'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end
  end

  describe 'GET /api/v1/admin/shops/{id}' do
    context 'when admin is authenticated' do
      it 'returns the shop with full menu details' do
        shop = create(:shop)
        menu = create(:menu, :with_category, shop: shop)

        get "/api/v1/admin/shops/#{shop.id}", headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to include(id: shop.id, name: shop.name)
        expect(json[:menus]).to be_an(Array)
        expect(json[:menus].first).to include(id: menu.id)
      end

      it 'returns 404 when shop does not exist' do
        get '/api/v1/admin/shops/99999', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        shop = create(:shop)
        get "/api/v1/admin/shops/#{shop.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/admin/shops' do
    let(:google_map_url) { 'https://maps.app.goo.gl/xyz' }
    let(:full_url) { 'https://www.google.com/maps/place/New+Shop/@35.6812,139.7671,17z/data=!3m1!4b1!4m6!3m5!1s0x60188b8e1234abcd:0x1234567890abcdef!8m2!3d35.6812!4d139.7671' }
    let(:api_key) { 'test_api_key' }

    context 'when admin is authenticated' do
      before do
        allow(ENV).to receive(:[]).with("GOOGLE_MAPS_API_KEY").and_return(api_key)
        stub_request(:get, google_map_url)
          .to_return(status: 301, headers: { 'Location' => full_url })
        stub_request(:post, "https://places.googleapis.com/v1/places:searchText")
          .with(headers: {
            'X-Goog-Api-Key' => api_key,
            'X-Goog-FieldMask' => 'places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.location'
          })
          .to_return(status: 200, body: {
            places: [{
              displayName: { text: 'New Shop' },
              formattedAddress: '東京都新宿区1',
              nationalPhoneNumber: '03-1234-5678',
              location: { latitude: 35.6812, longitude: 139.7671 }
            }]
          }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a new shop from Google Maps URL' do
        expect {
          post '/api/v1/admin/shops', params: { shop: { google_map_url: google_map_url } }, headers: admin_auth_headers_for(admin_user)
        }.to change(Shop, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to include(name: 'New Shop', address: '東京都新宿区1')
      end

      it 'returns unprocessable entity with invalid Google Maps URL' do
        expect {
          post '/api/v1/admin/shops', params: { shop: { google_map_url: 'https://example.com' } }, headers: admin_auth_headers_for(admin_user)
        }.not_to change(Shop, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to include(:errors)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        post '/api/v1/admin/shops', params: { shop: { google_map_url: google_map_url } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/admin/shops/{id}' do
    context 'when admin is authenticated' do
      it 'updates the shop with valid params' do
        shop = create(:shop, name: 'Old Name')

        patch "/api/v1/admin/shops/#{shop.id}",
              params: { shop: { name: 'New Name' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to include(name: 'New Name')
        expect(shop.reload.name).to eq('New Name')
      end

      it 'returns unprocessable entity with invalid params' do
        shop = create(:shop)

        patch "/api/v1/admin/shops/#{shop.id}",
              params: { shop: { name: '' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to include(:errors)
      end

      it 'returns 404 when shop does not exist' do
        patch '/api/v1/admin/shops/99999',
              params: { shop: { name: 'New Name' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        shop = create(:shop)
        patch "/api/v1/admin/shops/#{shop.id}", params: { shop: { name: 'New Name' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/admin/shops/{id}' do
    context 'when admin is authenticated' do
      it 'deletes the shop' do
        shop = create(:shop)

        expect {
          delete "/api/v1/admin/shops/#{shop.id}", headers: admin_auth_headers_for(admin_user)
        }.to change(Shop, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json).to include(message: 'Shop deleted successfully')
      end

      it 'returns 404 when shop does not exist' do
        delete '/api/v1/admin/shops/99999', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        shop = create(:shop)
        delete "/api/v1/admin/shops/#{shop.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
