require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  describe 'POST /api/v1/auth/google' do
    context 'with valid token' do
      it 'creates a new user and returns JWT token' do
        expect {
          post '/api/v1/auth/google', params: { token: 'valid_token' }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json).to match({
          token: be_a(String),
          user: {
            id: User.last.id,
            email: 'user@example.com',
            name: 'John Doe',
            image: 'https://lh3.googleusercontent.com/a/default-user'
          }
        })
      end

      it 'returns existing user if already exists' do
        user = create(:user, email: 'user@example.com')

        expect {
          post '/api/v1/auth/google', params: { token: 'valid_token' }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        expect(json).to match({
          token: be_a(String),
          user: {
            id: user.id,
            email: 'user@example.com',
            name: user.name,
            image: user.image
          }
        })
      end
    end

    context 'with invalid token', skip: 'まだ実装されていない' do
      it 'returns unauthorized error' do
        post '/api/v1/auth/google', params: { token: 'invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        expect(json).to eq({
          error: 'Invalid token'
        })
      end
    end

    context 'with missing token' do
      it 'returns unauthorized error' do
        post '/api/v1/auth/google'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to eq({
          error: 'Invalid token'
        })
      end
    end
  end
end
