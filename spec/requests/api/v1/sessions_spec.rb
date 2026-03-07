require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  describe 'POST /api/v1/auth/google' do
    let(:client_id) { 'test_client_id' }
    let(:valid_code) { 'valid_auth_code' }
    let(:redirect_uri) { 'https://ramen-ni-ai-wo.vercel.app/auth/callback' }
    let(:id_token) { 'valid_id_token' }

    before do
      allow(Rails.application.credentials).to receive(:gcp).and_return({
        client_id: client_id,
        client_secret: 'test_client_secret'
      })
    end

    context 'with valid token' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:)
      end

      it 'creates a new user and returns JWT token' do
        expect {
          post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }
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

      it 'returns existing user & updates if already exists' do
        user = create(:user, email: 'user@example.com')

        expect {
          post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }
        }.not_to change(User, :count)

        user.reload

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

    context 'with invalid token' do
      before do
        stub_google_code_exchange(code: 'invalid_token', redirect_uri:, status: 400)
      end

      it 'returns unauthorized error' do
        post '/api/v1/auth/google', params: { code: 'invalid_token', redirect_uri: }

        expect(response).to have_http_status(:unauthorized)
        expect(json).to eq({
          error: 'invalid_token',
          message: "Invalid or expired Google token"
        })
      end
    end

    context 'with missing token' do
      before do
        stub_request(:post, "https://oauth2.googleapis.com/token").to_return(
          status: 400,
          body: { error: 'invalid_grant' }.to_json,
          headers: { 'Content-Type': 'application/json' }
        )
      end

      it 'returns unauthorized error' do
        post '/api/v1/auth/google'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to eq({
          error: 'invalid_token',
          message: "Invalid or expired Google token"
        })
      end
    end
  end
end
