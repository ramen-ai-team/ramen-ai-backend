require 'rails_helper'

RSpec.describe GoogleMaps::PlaceIdExtractor do
  describe '.extract' do
    context 'with valid Google Maps URL containing Place ID' do
      let(:url) { 'https://www.google.com/maps/place/Ramen+Shop/@35.6812,139.7671,17z/data=!3m1!4b1!4m6!3m5!1s0x60188b8e1234abcd:0x1234567890abcdef!8m2!3d35.6812!4d139.7671' }

      it 'extracts Place ID from URL' do
        result = described_class.extract(url)
        expect(result).to eq('0x60188b8e1234abcd:0x1234567890abcdef')
      end
    end

    context 'with short URL format (goo.gl)' do
      let(:short_url) { 'https://maps.app.goo.gl/dGfTAMwDfw29yLPc7' }
      let(:full_url) { 'https://www.google.com/maps/place/Ramen+Shop/@35.6812,139.7671,17z/data=!3m1!4b1!4m6!3m5!1s0x60188b8e1234abcd:0x1234567890abcdef!8m2!3d35.6812!4d139.7671' }

      before do
        stub_request(:get, short_url)
          .to_return(status: 301, headers: { 'Location' => full_url })
      end

      it 'follows redirect and extracts Place ID from full URL' do
        result = described_class.extract(short_url)
        expect(result).to eq('0x60188b8e1234abcd:0x1234567890abcdef')
      end
    end

    context 'with invalid URL format' do
      let(:url) { 'https://example.com/not-a-google-maps-url' }

      it 'returns nil' do
        result = described_class.extract(url)
        expect(result).to be_nil
      end
    end

    context 'with empty URL' do
      let(:url) { '' }

      it 'returns nil' do
        result = described_class.extract(url)
        expect(result).to be_nil
      end
    end

    context 'with nil URL' do
      let(:url) { nil }

      it 'returns nil' do
        result = described_class.extract(url)
        expect(result).to be_nil
      end
    end
  end
end
