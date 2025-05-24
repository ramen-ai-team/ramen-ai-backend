require 'rails_helper'

require 'rails_helper'

RSpec.describe Api::V1::ShopsController, type: :request do
  describe 'GET /api/v1/shops' do
    let!(:shop) { create(:shop, name: 'Shop Name') }

    it 'returns all shops' do
      get '/api/v1/shops'
      expect(response.status).to eq 200
      expect(json).to eq({
        shops: [{
          id: shop.id,
          name: 'Shop Name'
        }]
      })
    end
  end

  describe 'GET /api/v1/shops/:id' do
    let!(:shop) { create(:shop, name: 'Shop Name') }

    it 'returns a specific shop' do
      get "/api/v1/shops/#{shop.id}"
      expect(response.status).to eq 200
      expect(json).to eq({
        id: shop.id,
        name: 'Shop Name'
      })
    end
  end

  describe 'POST /api/v1/shops' do
    let!(:shop) { create(:shop, name: 'Existing Shop') }

    it 'creates a new shop' do
      post '/api/v1/shops', params: { shop: { name: 'New Shop' } }
      expect(response.status).to eq 201
      expect(json).to eq({
        id: shop.id + 1,
        name: 'New Shop'
      })
    end

    it 'returns an error when name is missing' do
      post '/api/v1/shops', params: { shop: { name: '' } }
      expect(response.status).to eq 422
      expect(json[:name]).to include("can't be blank")
    end
  end

  describe 'PATCH /api/v1/shops/:id' do
    let!(:shop) { create(:shop, name: 'Old Shop Name') }

    it 'updates an existing shop' do
      patch "/api/v1/shops/#{shop.id}", params: { shop: { name: 'Updated Shop Name' } }
      expect(response.status).to eq 200
      expect(json).to eq({
        id: shop.id,
        name: 'Updated Shop Name'
      })
    end

    it 'returns an error when name is missing' do
      patch "/api/v1/shops/#{shop.id}", params: { shop: { name: '' } }
      expect(response.status).to eq 422
      expect(json[:name]).to include("can't be blank")
    end
  end

  describe 'DELETE /api/v1/shops/:id' do
    let!(:shop) { create(:shop, name: 'Shop to Delete') }

    it 'deletes a shop' do
      delete "/api/v1/shops/#{shop.id}"
      expect(response.status).to eq 204
      expect(Shop.exists?(shop.id)).to be_falsey
    end

    it 'returns 404 if shop does not exist' do
      delete '/api/v1/shops/9999'
      expect(response.status).to eq 404
    end
  end
end
