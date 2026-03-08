require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  describe 'POST /api/v1/auth/google' do
    let(:client_id) { 'test_client_id' }
    let(:valid_code) { 'valid_auth_code' }
    let(:redirect_uri) { 'https://ramen-ni-ai-wo.vercel.app/auth/callback' }
    let(:id_token) { 'valid_id_token' }
    let(:valid_tokeninfo_response) do
      {
        'aud' => client_id,
        'iss' => 'https://accounts.google.com',
        'sub' => 'google_123',
        'email' => 'user@example.com',
        'name' => 'Test User',
        'picture' => 'https://example.com/avatar.jpg',
        'email_verified' => 'true',
        'exp' => (Time.current + 1.hour).to_i.to_s
      }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GCP_CLIENT_ID").and_return(client_id)
      allow(ENV).to receive(:[]).with("GCP_CLIENT_SECRET").and_return('test_client_secret')
    end

    context 'with valid Google code' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: valid_tokeninfo_response.to_json)
      end

      context 'when user does not exist' do
        it 'creates a new user and returns JWT token' do
          expect {
            post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }
          }.to change(User, :count).by(1)

          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('token')
          expect(json_response).to have_key('user')
          expect(json_response['user']['email']).to eq('user@example.com')
          expect(json_response['user']['name']).to eq('Test User')
        end
      end

      context 'when user already exists with google_id' do
        let!(:existing_user) do
          create(:user,
            google_id: 'google_123',
            email: 'user@example.com',
            name: 'Old Name',
            provider: 'google',
            uid: 'google_123'
          )
        end

        it 'updates existing user and returns JWT token' do
          expect {
            post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['user']['name']).to eq('Test User')

          existing_user.reload
          expect(existing_user.name).to eq('Test User')
        end
      end

      context 'when user exists with same email but no google_id' do
        let!(:existing_user) do
          create(:user,
            email: 'user@example.com',
            name: 'Existing User',
            provider: 'other',
            uid: 'other_123'
          )
        end

        it 'links Google ID to existing user' do
          expect {
            post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:ok)

          existing_user.reload
          expect(existing_user.google_id).to eq('google_123')
        end
      end
    end

    context 'when code exchange fails' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, status: 400)
      end

      it 'returns unauthorized error' do
        post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }

        expect(response).to have_http_status(:unauthorized)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('invalid_token')
        expect(json_response['message']).to eq('Invalid or expired Google token')
      end
    end

    context 'when user creation fails with invalid data' do
      before do
        invalid_response = valid_tokeninfo_response.merge('email' => '')
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: invalid_response.to_json)
      end

      it 'returns internal server error' do
        post '/api/v1/auth/google', params: { code: valid_code, redirect_uri: }

        expect(response).to have_http_status(:internal_server_error)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('authentication_failed')
        expect(json_response['message']).to eq('Authentication process failed')
      end
    end

    context 'with missing code parameter' do
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
      end
    end
  end
end
