require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Reviews', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/reviews' do
    context 'when admin is authenticated' do
      it 'returns all reviews with associations' do
        user = create(:user, name: 'テストユーザー', email: 'test@example.com')
        shop = create(:shop, name: 'ラーメン店')
        menu = create(:menu, name: '醤油ラーメン', shop: shop)
        review = create(:review, user: user, menu: menu, rating: 4, comment: 'おいしい', visited_at: '2026-04-01')

        get '/api/v1/admin/reviews', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(1)
        expect(json.first).to include(
          id: review.id,
          rating: 4,
          comment: 'おいしい',
          visited_at: '2026-04-01',
          user: include(id: user.id, name: 'テストユーザー', email: 'test@example.com'),
          menu: include(id: menu.id, name: '醤油ラーメン', shop: include(id: shop.id, name: 'ラーメン店'))
        )
      end

      it 'returns empty array when no reviews exist' do
        get '/api/v1/admin/reviews', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/reviews'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end
  end
end
