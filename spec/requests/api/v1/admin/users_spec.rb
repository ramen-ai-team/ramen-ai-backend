require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Users', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/users' do
    context 'when admin is authenticated' do
      it 'returns all users' do
        # Arrange: Create some users
        user1 = create(:user, email: 'user1@example.com', name: 'User One', image: 'https://example.com/image1.png')
        user2 = create(:user, email: 'user2@example.com', name: 'User Two', image: 'https://example.com/image2.png')

        # Act: Make the request
        get '/api/v1/admin/users', headers: admin_auth_headers_for(admin_user)

        # Assert
        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)

        # Check first user
        expect(json.first).to match(
          id: user1.id,
          email: 'user1@example.com',
          name: 'User One',
          provider: 'google',
          uid: user1.uid,
          image: 'https://example.com/image1.png',
          google_id: nil,
          email_verified: false,
          created_at: kind_of(String),
          updated_at: kind_of(String)
        )

        # Check second user
        expect(json.second).to match(
          id: user2.id,
          email: 'user2@example.com',
          name: 'User Two',
          provider: 'google',
          uid: user2.uid,
          image: 'https://example.com/image2.png',
          google_id: nil,
          email_verified: false,
          created_at: kind_of(String),
          updated_at: kind_of(String)
        )
      end

      it 'returns empty array when no users exist' do
        # Act
        get '/api/v1/admin/users', headers: admin_auth_headers_for(admin_user)

        # Assert
        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        # Act: Make request without auth headers
        get '/api/v1/admin/users'

        # Assert
        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end

    context 'when token is invalid' do
      it 'returns unauthorized error' do
        # Act: Make request with invalid token
        get '/api/v1/admin/users', headers: { 'Authorization' => 'Bearer invalid_token' }

        # Assert
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
