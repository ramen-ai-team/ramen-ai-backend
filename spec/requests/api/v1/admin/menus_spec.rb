require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Menus', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/menus' do
    context 'when admin is authenticated' do
      it 'returns all menus with associations' do
        menu = create(:menu, :with_category)

        get '/api/v1/admin/menus', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(1)
        expect(json.first).to include(id: menu.id, name: menu.name)
        expect(json.first).to have_key(:shop)
        expect(json.first).to have_key(:genre)
        expect(json.first).to have_key(:soup)
        expect(json.first).to have_key(:noodle)
      end

      it 'returns empty array when no menus exist' do
        get '/api/v1/admin/menus', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/menus'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end
  end

  describe 'GET /api/v1/admin/menus/{id}' do
    context 'when admin is authenticated' do
      it 'returns the menu with associations' do
        menu = create(:menu, :with_category)

        get "/api/v1/admin/menus/#{menu.id}", headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to include(id: menu.id, name: menu.name)
        expect(json).to have_key(:shop)
        expect(json).to have_key(:genre)
        expect(json).to have_key(:soup)
        expect(json).to have_key(:noodle)
      end

      it 'returns 404 when menu does not exist' do
        get '/api/v1/admin/menus/99999', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        menu = create(:menu)
        get "/api/v1/admin/menus/#{menu.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/admin/menus' do
    context 'when admin is authenticated' do
      it 'creates a new menu with valid params' do
        shop = create(:shop)
        genre = create(:genre)
        soup = create(:soup)
        noodle = create(:noodle)
        image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/images/ramen.png'), 'image/png')

        expect {
          post '/api/v1/admin/menus',
               params: { menu: { name: 'Miso Ramen', shop_id: shop.id, genre_id: genre.id, soup_id: soup.id, noodle_id: noodle.id, image: image } },
               headers: admin_auth_headers_for(admin_user)
        }.to change(Menu, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to include(name: 'Miso Ramen')
        expect(json[:shop]).to include(id: shop.id)
        expect(json[:genre]).to include(id: genre.id)
      end

      it 'creates a menu without optional associations' do
        shop = create(:shop)
        image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/images/ramen.png'), 'image/png')

        expect {
          post '/api/v1/admin/menus',
               params: { menu: { name: 'Simple Ramen', shop_id: shop.id, image: image } },
               headers: admin_auth_headers_for(admin_user)
        }.to change(Menu, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to include(name: 'Simple Ramen')
      end

      it 'returns unprocessable entity with invalid params' do
        expect {
          post '/api/v1/admin/menus',
               params: { menu: { name: '' } },
               headers: admin_auth_headers_for(admin_user)
        }.not_to change(Menu, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to include(:errors)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        post '/api/v1/admin/menus', params: { menu: { name: 'Ramen' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/admin/menus/{id}' do
    context 'when admin is authenticated' do
      it 'updates the menu name' do
        menu = create(:menu, name: 'Old Name')

        patch "/api/v1/admin/menus/#{menu.id}",
              params: { menu: { name: 'New Name' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to include(name: 'New Name')
        expect(menu.reload.name).to eq('New Name')
      end

      it 'updates genre association' do
        menu = create(:menu, :with_category)
        new_genre = create(:genre, name: 'Tsukemen')

        patch "/api/v1/admin/menus/#{menu.id}",
              params: { menu: { genre_id: new_genre.id } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json[:genre]).to include(id: new_genre.id)
      end

      it 'returns unprocessable entity with invalid params' do
        menu = create(:menu)

        patch "/api/v1/admin/menus/#{menu.id}",
              params: { menu: { name: '' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to include(:errors)
      end

      it 'returns 404 when menu does not exist' do
        patch '/api/v1/admin/menus/99999',
              params: { menu: { name: 'New Name' } },
              headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        menu = create(:menu)
        patch "/api/v1/admin/menus/#{menu.id}", params: { menu: { name: 'New Name' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/admin/menus/{id}' do
    context 'when admin is authenticated' do
      it 'deletes the menu' do
        menu = create(:menu)

        expect {
          delete "/api/v1/admin/menus/#{menu.id}", headers: admin_auth_headers_for(admin_user)
        }.to change(Menu, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json).to include(message: 'Menu deleted successfully')
      end

      it 'returns 404 when menu does not exist' do
        delete '/api/v1/admin/menus/99999', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        menu = create(:menu)
        delete "/api/v1/admin/menus/#{menu.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
