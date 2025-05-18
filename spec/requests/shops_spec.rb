require 'rails_helper'

RSpec.describe ShopsController, type: :request do
  describe 'GET /shops' do
    let!(:shop) { create(:shop, name: 'Shop Name') }

    it 'returns all shops' do
      get '/shops'
      expect(response.status).to eq 200
      expect(json).to eq({
        shops: [{
          id: shop.id,
          name: 'Shop Name'
        }]
      })
    end
  end

  describe 'GET /shops/:id' do
    let!(:shop) { create(:shop, name: 'Shop Name') }

    it 'returns a specific shop' do
      get "/shops/#{shop.id}"
      expect(response.status).to eq 200
      expect(json).to eq({
        id: shop.id,
        name: 'Shop Name'
      })
    end
  end

  describe 'POST /shops' do
    let!(:shop) { create(:shop, name: 'Existing Shop') }

    it 'creates a new shop' do
      post '/shops', params: { shop: { name: 'New Shop' } }
      expect(response.status).to eq 201
      expect(json).to eq({
        id: shop.id + 1,
        name: 'New Shop'
      })
    end

    it 'returns an error when name is missing' do
      post '/shops', params: { shop: { name: '' } }
      expect(response.status).to eq 422
      expect(json[:name]).to include("can't be blank")
    end
  end

  describe 'PATCH /shops/:id' do
    let!(:shop) { create(:shop, name: 'Old Shop Name') }

    it 'updates an existing shop' do
      patch "/shops/#{shop.id}", params: { shop: { name: 'Updated Shop Name' } }
      expect(response.status).to eq 200
      expect(json).to eq({
        id: shop.id,
        name: 'Updated Shop Name'
      })
    end

    it 'returns an error when name is missing' do
      patch "/shops/#{shop.id}", params: { shop: { name: '' } }
      expect(response.status).to eq 422
      expect(json[:name]).to include("can't be blank")
    end
  end

  describe 'DELETE /shops/:id' do
    let!(:shop) { create(:shop, name: 'Shop to Delete') }

    it 'deletes a shop' do
      delete "/shops/#{shop.id}"
      expect(response.status).to eq 204
      expect(Shop.exists?(shop.id)).to be_falsey
    end

    it 'returns 404 if shop does not exist' do
      delete '/shops/9999'
      expect(response.status).to eq 404
    end
  end
end
