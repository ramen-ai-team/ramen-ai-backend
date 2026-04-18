require 'rails_helper'

RSpec.describe 'Api::V1::Admin::MenuReports', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /api/v1/admin/menu_reports' do
    context 'when admin is authenticated' do
      it 'returns all menu_reports with reviews included in menu' do
        user = create(:user, name: 'テストユーザー', email: 'test@example.com')
        shop = create(:shop, name: 'ラーメン店')
        menu = create(:menu, name: '醤油ラーメン', shop: shop)
        genre = create(:genre, name: '醤油')
        noodle = create(:noodle, name: '細麺')
        soup = create(:soup, name: '鶏白湯')
        menu_report = create(:menu_report, user: user, menu: menu, genre: genre, noodle: noodle, soup: soup)
        review = create(:review, menu: menu, rating: 4, comment: 'おいしい', visited_at: '2026-04-01')

        get '/api/v1/admin/menu_reports', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.size).to eq(1)
        expect(json.first).to include(
          id: menu_report.id,
          user: include(id: user.id, name: 'テストユーザー', email: 'test@example.com'),
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

      it 'returns menu with empty reviews when no reviews exist' do
        create(:menu_report)

        get '/api/v1/admin/menu_reports', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json.first[:menu]).to include(reviews: [])
      end

      it 'returns empty array when no menu_reports exist' do
        get '/api/v1/admin/menu_reports', headers: admin_auth_headers_for(admin_user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end

    context 'when admin is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/admin/menu_reports'

        expect(response).to have_http_status(:unauthorized)
        expect(json).to include(error: 'Unauthorized')
      end
    end
  end
end
