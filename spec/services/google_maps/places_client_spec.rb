require 'rails_helper'

RSpec.describe GoogleMaps::PlacesClient do
  describe '.fetch_place_details' do
    let(:search_info) { { name: 'ラーメン太郎', latitude: 35.6812, longitude: 139.7671 } }
    let(:api_key) { 'test_api_key' }

    before do
      allow(ENV).to receive(:[]).with("GOOGLE_MAPS_API_KEY").and_return(api_key)
    end

    context 'when place is found' do
      let(:response_body) do
        {
          places: [
            {
              displayName: { text: 'ラーメン太郎' },
              formattedAddress: '東京都渋谷区道玄坂1-2-3',
              nationalPhoneNumber: '03-1234-5678',
              location: { latitude: 35.6812, longitude: 139.7671 }
            }
          ]
        }.to_json
      end

      before do
        stub_request(:post, "https://places.googleapis.com/v1/places:searchText")
          .with(headers: {
            'X-Goog-Api-Key' => api_key,
            'X-Goog-FieldMask' => 'places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.location'
          })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns place details' do
        result = described_class.fetch_place_details(search_info)

        expect(result).to eq({
          name: 'ラーメン太郎',
          address: '東京都渋谷区道玄坂1-2-3',
          phone_number: '03-1234-5678',
          latitude: 35.6812,
          longitude: 139.7671
        })
      end
    end

    context 'when no places are found' do
      let(:response_body) { { places: [] }.to_json }

      before do
        stub_request(:post, "https://places.googleapis.com/v1/places:searchText")
          .with(headers: {
            'X-Goog-Api-Key' => api_key,
            'X-Goog-FieldMask' => 'places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.location'
          })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(search_info)
        expect(result).to be_nil
      end
    end

    context 'when API returns error status' do
      before do
        stub_request(:post, "https://places.googleapis.com/v1/places:searchText")
          .with(headers: {
            'X-Goog-Api-Key' => api_key,
            'X-Goog-FieldMask' => 'places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.location'
          })
          .to_return(status: 500, body: '', headers: {})
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(search_info)
        expect(result).to be_nil
      end
    end

    context 'when API key is not configured' do
      before do
        allow(ENV).to receive(:[]).with("GOOGLE_MAPS_API_KEY").and_return(nil)
      end

      it 'logs error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Google Maps API key is not configured/)

        result = described_class.fetch_place_details(search_info)
        expect(result).to be_nil
      end
    end
  end
end
