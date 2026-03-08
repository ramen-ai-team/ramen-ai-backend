require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Noodles', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/noodles' do
    context 'when admin is authenticated' do
      it 'returns all noodles' do
        noodle1 = create(:noodle, name: 'Thin')
        noodle2 = create(:noodle, name: 'Thick')

        get '/api/v1/admin/noodles', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)
        expect(json.map { |n| n[:name] }).to contain_exactly('Thin', 'Thick')
      end

      it 'returns empty array when no noodles exist' do
        get '/api/v1/admin/noodles', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/noodles'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end

    context 'when token is invalid' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/noodles', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
