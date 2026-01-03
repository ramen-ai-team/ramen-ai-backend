require 'rails_helper'

RSpec.describe GoogleMaps::PlacesClient do
  describe '.fetch_place_details' do
    let(:place_id) { 'ChIJ1234567890abcdef' }
    let(:api_key) { 'test_api_key' }

    before do
      allow(Rails.application.credentials).to receive(:google_maps_api_key).and_return(api_key)
    end

    context 'with valid place_id' do
      let(:response_body) do
        {
          result: {
            name: 'ラーメン太郎',
            formatted_address: '東京都渋谷区道玄坂1-2-3',
            formatted_phone_number: '03-1234-5678',
            place_id: place_id
          },
          status: 'OK'
        }.to_json
      end

      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns place details' do
        result = described_class.fetch_place_details(place_id)

        expect(result).to eq({
          name: 'ラーメン太郎',
          address: '東京都渋谷区道玄坂1-2-3',
          phone_number: '03-1234-5678'
        })
      end
    end

    context 'with invalid place_id' do
      let(:response_body) do
        {
          result: {},
          status: 'INVALID_REQUEST'
        }.to_json
      end

      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end

    context 'when API returns error status' do
      before do
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json")
          .with(query: { place_id: place_id, key: api_key, fields: 'name,formatted_address,formatted_phone_number', language: 'ja' })
          .to_return(status: 500, body: '', headers: {})
      end

      it 'returns nil' do
        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end

    context 'when API key is not configured' do
      before do
        allow(Rails.application.credentials).to receive(:google_maps_api_key).and_return(nil)
      end

      it 'logs error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Google Maps API key is not configured/)

        result = described_class.fetch_place_details(place_id)
        expect(result).to be_nil
      end
    end
  end
end
