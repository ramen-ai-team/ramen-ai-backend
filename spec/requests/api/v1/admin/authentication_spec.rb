require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Authentication', type: :request do
  describe 'POST /api/v1/admin/auth' do
    let(:admin_user) { create(:admin_user, email: 'admin@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token and admin user info' do
        post '/api/v1/admin/auth', params: { email: admin_user.email, password: 'password123' }

        expect(response).to have_http_status(:ok)
        expect(json).to include(:token)
        expect(json[:admin_user]).to match(
          id: admin_user.id,
          email: admin_user.email
        )
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized error' do
        post '/api/v1/admin/auth', params: { email: admin_user.email, password: 'wrong_password' }

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Invalid credentials')
      end
    end

    context 'with non-existent email' do
      it 'returns unauthorized error' do
        post '/api/v1/admin/auth', params: { email: 'notfound@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Invalid credentials')
      end
    end
  end

  describe 'DELETE /api/v1/admin/auth' do
    let(:admin_user) { create(:admin_user) }

    context 'when admin is authenticated' do
      it 'returns logout success message' do
        delete '/api/v1/admin/auth', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to include(message: 'Logged out successfully')
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        delete '/api/v1/admin/auth'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
