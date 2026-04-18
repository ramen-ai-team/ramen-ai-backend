require 'rails_helper'

RSpec.describe GoogleMaps::PlacesClient do
  describe '.fetch_place_details' do
    let(:place_id) { 'ChIJ1234567890abcdef' }
    let(:api_key) { 'test_api_key' }

    before do
      allow(ENV).to receive(:[]).with("GOOGLE_MAPS_API_KEY").and_return(api_key)
    end

    context 'with valid place_id' do
      let(:response_body) do
        {
          displayName: { text: 'ラーメン太郎' },
          formattedAddress: '東京都渋谷区道玄坂1-2-3',
          nationalPhoneNumber: '03-1234-5678',
          location: { latitude: 35.6812, longitude: 139.7671 }
        }.to_json
      end

      before do
        stub_request(:get, "https://places.googleapis.com/v1/places/#{place_id}")
          .with(
            query: { languageCode: 'ja' },
            headers: {
              'X-Goog-Api-Key' => api_key,
              'X-Goog-FieldMask' => 'displayName,formattedAddress,nationalPhoneNumber,location'
            }
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns place details' do
        result = described_class.fetch_place_details(place_id)

        expect(result).to eq({
          name: 'ラーメン太郎',
          address: '東京都渋谷区道玄坂1-2-3',
          phone_number: '03-1234-5678',
          latitude: 35.6812,
          longitude: 139.7671
        })
      end
    end

    context 'with invalid place_id' do
      let(:response_body) do
        {
          error: {
            code: 404,
            message: 'Requested entity was not found.',
            status: 'NOT_FOUND'
          }
        }.to_json
      end

      before do
        stub_request(:get, "https://places.googleapis.com/v1/places/#{place_id}")
          .with(
            query: { languageCode: 'ja' },
            headers: {
              'X-Goog-Api-Key' => api_key,
              'X-Goog-FieldMask' => 'displayName,formattedAddress,nationalPhoneNumber,location'
            }
          )
          .to_return(status: 404, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end

    context 'when API returns error status' do
      before do
        stub_request(:get, "https://places.googleapis.com/v1/places/#{place_id}")
          .with(
            query: { languageCode: 'ja' },
            headers: {
              'X-Goog-Api-Key' => api_key,
              'X-Goog-FieldMask' => 'displayName,formattedAddress,nationalPhoneNumber,location'
            }
          )
          .to_return(status: 500, body: '', headers: {})
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end

    context 'when API key is not configured' do
      before do
        allow(ENV).to receive(:[]).with("GOOGLE_MAPS_API_KEY").and_return(nil)
      end

      it 'logs error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Google Maps API key is not configured/)

        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end
  end
end
