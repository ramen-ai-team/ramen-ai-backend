require 'rails_helper'

RSpec.describe GoogleTokenVerifier do
  describe '.verify' do
    let(:valid_token) { 'valid_google_token' }
    let(:invalid_token) { 'invalid_google_token' }
    let(:client_id) { 'test_client_id' }

    let(:valid_token_response) do
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
      allow(Rails.application.credentials).to receive(:google).and_return({ client_id: client_id })
    end

    context 'with valid token' do
      before do
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{valid_token}")
          .to_return(
            status: 200,
            body: valid_token_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns normalized user data' do
        result = described_class.verify(valid_token)

        expect(result).to eq({
          google_id: 'google_user_123',
          email: 'user@example.com',
          name: 'Test User',
          picture: 'https://example.com/photo.jpg',
          email_verified: true
        })
      end
    end

    context 'with token having wrong audience' do
      before do
        invalid_response = valid_token_response.merge('aud' => 'wrong_client_id')
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{valid_token}")
          .to_return(
            status: 200,
            body: invalid_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil' do
        result = described_class.verify(valid_token)
        expect(result).to be_nil
      end
    end

    context 'with token having wrong issuer' do
      before do
        invalid_response = valid_token_response.merge('iss' => 'https://wrong-issuer.com')
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{valid_token}")
          .to_return(
            status: 200,
            body: invalid_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil' do
        result = described_class.verify(valid_token)
        expect(result).to be_nil
      end
    end

    context 'with expired token' do
      before do
        expired_response = valid_token_response.merge('exp' => (Time.current - 1.hour).to_i.to_s)
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{valid_token}")
          .to_return(
            status: 200,
            body: expired_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil' do
        result = described_class.verify(valid_token)
        expect(result).to be_nil
      end
    end

    context 'with HTTP error response' do
      before do
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{invalid_token}")
          .to_return(status: 400, body: { error: 'invalid_token' }.to_json)
      end

      it 'returns nil' do
        result = described_class.verify(invalid_token)
        expect(result).to be_nil
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{valid_token}")
          .to_raise(StandardError.new('Network error'))
      end

      it 'logs error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Google token verification failed: Network error/)

        result = described_class.verify(valid_token)
        expect(result).to be_nil
      end
    end
  end
end