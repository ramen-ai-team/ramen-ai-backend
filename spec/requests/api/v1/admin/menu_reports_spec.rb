require 'rails_helper'

RSpec.describe 'Api::V1::Admin::MenuReports', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user, name: 'テストユーザー', email: 'test@example.com') }

  describe 'GET /api/v1/admin/users/:user_id/menu_reports' do
    context 'when admin is authenticated' do
      it 'returns menu_reports for the user with reviews included' do
        shop = create(:shop, name: 'ラーメン店')
        menu = create(:menu, name: '醤油ラーメン', shop: shop)
        genre = create(:genre, name: '醤油')
        noodle = create(:noodle, name: '細麺')
        soup = create(:soup, name: '鶏白湯')
        menu_report = create(:menu_report, user: user, menu: menu, genre: genre, noodle: noodle, soup: soup)
        review = create(:review, menu: menu, rating: 4, comment: 'おいしい', visited_at: '2026-04-01')

        get "/api/v1/admin/users/#{user.id}/menu_reports", headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(1)
        expect(json.first).to include(
          id: menu_report.id,
          menu: include(
            id: menu.id,
            name: '醤油ラーメン',
            shop: include(id: shop.id, name: 'ラーメン店'),
            reviews: [include(id: review.id, rating: 4, comment: 'おいしい', visited_at: '2026-04-01')]
          ),
          genre: include(id: genre.id, name: '醤油'),
          noodle: include(id: noodle.id, name: '細麺'),
          soup: include(id: soup.id, name: '鶏白湯'),
          image_urls: []
        )
      end

      it 'does not return menu_reports of other users' do
        other_user = create(:user)
        create(:menu_report, user: other_user)

        get "/api/v1/admin/users/#{user.id}/menu_reports", headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end

      it 'returns 404 when user does not exist' do
        get '/api/v1/admin/users/99999/menu_reports', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:not_found)
      end

      it 'returns empty array when user has no menu_reports' do
        get "/api/v1/admin/users/#{user.id}/menu_reports", headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get "/api/v1/admin/users/#{user.id}/menu_reports"

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end
  end
end
