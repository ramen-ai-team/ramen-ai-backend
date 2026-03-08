require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Soups', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/soups' do
    context 'when admin is authenticated' do
      it 'returns all soups' do
        soup1 = create(:soup, name: 'Tonkotsu')
        soup2 = create(:soup, name: 'Shoyu')

        get '/api/v1/admin/soups', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)
        expect(json.map { |s| s[:name] }).to contain_exactly('Tonkotsu', 'Shoyu')
      end

      it 'returns empty array when no soups exist' do
        get '/api/v1/admin/soups', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/soups'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end

    context 'when token is invalid' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/soups', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
