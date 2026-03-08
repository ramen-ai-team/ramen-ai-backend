require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Genres', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/genres' do
    context 'when admin is authenticated' do
      it 'returns all genres' do
        genre1 = create(:genre, name: 'Shoyu')
        genre2 = create(:genre, name: 'Miso')

        get '/api/v1/admin/genres', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)
        expect(json.map { |g| g[:name] }).to contain_exactly('Shoyu', 'Miso')
      end

      it 'returns empty array when no genres exist' do
        get '/api/v1/admin/genres', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/genres'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end

    context 'when token is invalid' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/genres', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
