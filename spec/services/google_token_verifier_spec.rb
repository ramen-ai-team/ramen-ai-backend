require 'rails_helper'

RSpec.describe GoogleTokenVerifier do
  let(:valid_code) { 'valid_auth_code' }
  let(:redirect_uri) { 'https://example.com/callback' }
  let(:id_token) { 'valid_id_token' }
  let(:client_id) { 'test_client_id' }

  let(:valid_tokeninfo_response) do
    {
      'aud' => client_id,
      'iss' => 'https://accounts.google.com',
      'sub' => 'google_user_123',
      'email' => 'user@example.com',
      'name' => 'Test User',
      'picture' => 'https://example.com/photo.jpg',
      'email_verified' => 'true',
      'exp' => (Time.current + 1.hour).to_i.to_s
    }
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GCP_CLIENT_ID").and_return(client_id)
    allow(ENV).to receive(:[]).with("GCP_CLIENT_SECRET").and_return('test_client_secret')
  end

  describe '.verify' do
    context 'with valid code' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: valid_tokeninfo_response.to_json)
      end

      it 'returns normalized user data' do
        result = described_class.verify(valid_code, redirect_uri)

        expect(result).to eq({
          google_id: 'google_user_123',
          email: 'user@example.com',
          name: 'Test User',
          picture: 'https://example.com/photo.jpg',
          email_verified: true
        })
      end
    end

    context 'when code exchange fails' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, status: 400)
      end

      it 'returns false' do
        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end

    context 'when tokeninfo has wrong audience' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: valid_tokeninfo_response.merge('aud' => 'wrong_client_id').to_json)
      end

      it 'returns false' do
        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end

    context 'when tokeninfo has wrong issuer' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: valid_tokeninfo_response.merge('iss' => 'https://wrong-issuer.com').to_json)
      end

      it 'returns false' do
        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end

    context 'when token is expired' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, response_body: valid_tokeninfo_response.merge('exp' => (Time.current - 1.hour).to_i.to_s).to_json)
      end

      it 'returns false' do
        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end

    context 'when tokeninfo returns HTTP error' do
      before do
        stub_google_code_exchange(code: valid_code, redirect_uri:, id_token:)
        stub_google_token_verifier(id_token:, status: 400)
      end

      it 'returns false' do
        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow(HTTParty).to receive(:post).and_raise(StandardError, "connection error")
      end

      it 'logs error and returns false' do
        expect(Rails.logger).to receive(:error).with(/Google token verification failed/)

        result = described_class.verify(valid_code, redirect_uri)
        expect(result).to eq false
      end
    end
  end
end
