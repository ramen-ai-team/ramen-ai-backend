require 'rails_helper'

RSpec.describe Api::V1::ReviewsController, type: :request do
  let(:user) { create(:user) }
  let(:menu) { create(:menu) }

  let(:menu_json) do
    {
      id: menu.id,
      name: menu.name,
      genre_name: nil,
      noodle_name: nil,
      soup_name: nil,
      image_url: a_string_starting_with('http')
    }
  end

  describe 'POST /api/v1/menus/:menu_id/reviews' do
    let(:params) do
      {
        rating: 4,
        comment: 'スープが濃厚でうまい',
        visited_at: '2026-03-21'
      }
    end

    context '認証済みの場合' do
      it 'レビューを作成できる' do
        expect {
          post "/api/v1/menus/#{menu.id}/reviews", params: params, headers: auth_headers_for(user)
        }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to match({
          id: Review.last.id,
          rating: 4,
          comment: 'スープが濃厚でうまい',
          visited_at: '2026-03-21',
          menu: menu_json
        })
      end

      it 'commentが空文字でも作成できる' do
        post "/api/v1/menus/#{menu.id}/reviews",
          params: params.merge(comment: ''),
          headers: auth_headers_for(user)

        expect(response).to have_http_status(:created)
        expect(json).to match({
          id: Review.last.id,
          rating: 4,
          comment: '',
          visited_at: '2026-03-21',
          menu: menu_json
        })
      end

      it '同じユーザーが同じメニューに複数回作成できる' do
        create(:review, user: user, menu: menu)

        expect {
          post "/api/v1/menus/#{menu.id}/reviews", params: params, headers: auth_headers_for(user)
        }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'ratingなしは422を返す' do
        post "/api/v1/menus/#{menu.id}/reviews",
          params: params.except(:rating),
          headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'rating範囲外は422を返す' do
        post "/api/v1/menus/#{menu.id}/reviews",
          params: params.merge(rating: 6),
          headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'visited_atなしは422を返す' do
        post "/api/v1/menus/#{menu.id}/reviews",
          params: params.except(:visited_at),
          headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it '存在しないmenu_idは404を返す' do
        post "/api/v1/menus/0/reviews", params: params, headers: auth_headers_for(user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        post "/api/v1/menus/#{menu.id}/reviews", params: params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/menus/:menu_id/reviews/:id' do
    let!(:review) { create(:review, user: user, menu: menu, rating: 3, comment: '普通', visited_at: '2026-01-01') }

    context '自分のレビューの場合' do
      it 'レビューを更新できる' do
        patch "/api/v1/menus/#{menu.id}/reviews/#{review.id}",
          params: { rating: 5, comment: '最高！', visited_at: '2026-03-21' },
          headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json).to match({
          id: review.id,
          rating: 5,
          comment: '最高！',
          visited_at: '2026-03-21',
          menu: menu_json
        })
      end
    end

    context '他人のレビューの場合' do
      it '404を返す' do
        other_user = create(:user)

        patch "/api/v1/menus/#{menu.id}/reviews/#{review.id}",
          params: { rating: 5 },
          headers: auth_headers_for(other_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        patch "/api/v1/menus/#{menu.id}/reviews/#{review.id}", params: { rating: 5 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
