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

  describe 'GET /api/v1/admin/shops/:id' do
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
    context 'when admin is authenticated' do
      it 'creates a new shop with valid params' do
        shop_params = { shop: { name: 'New Shop', address: '東京都新宿区1', google_map_url: 'https://maps.app.goo.gl/xyz' } }

        expect {
          post '/api/v1/admin/shops', params: shop_params, headers: admin_auth_headers_for(admin_user)
        }.to change(Shop, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to include(name: 'New Shop', address: '東京都新宿区1')
      end

      it 'returns unprocessable entity with invalid params' do
        shop_params = { shop: { name: '', address: '東京都新宿区1', google_map_url: 'https://maps.app.goo.gl/xyz' } }

        expect {
          post '/api/v1/admin/shops', params: shop_params, headers: admin_auth_headers_for(admin_user)
        }.not_to change(Shop, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to include(:errors)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        post '/api/v1/admin/shops', params: { shop: { name: 'New Shop' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/admin/shops/:id' do
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

  describe 'DELETE /api/v1/admin/shops/:id' do
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
