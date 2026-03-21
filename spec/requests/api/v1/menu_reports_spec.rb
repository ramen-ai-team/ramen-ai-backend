require 'rails_helper'

RSpec.describe Api::V1::MenuReportsController, type: :request do
  describe 'POST /api/v1/menu_reports' do
    let(:user) { create(:user) }
    let(:shop) { create(:shop) }
    let(:menu) { create(:menu, shop: shop) }
    let(:genre) { create(:genre) }
    let(:noodle) { create(:noodle) }
    let(:soup) { create(:soup) }

    context '既存メニューに紐づける場合' do
      let(:params) do
        {
          menu_id: menu.id,
          genre_id: genre.id,
          noodle_id: noodle.id,
          soup_id: soup.id
        }
      end

      it 'menu_reportを作成できる' do
        expect {
          post '/api/v1/menu_reports', params: params, headers: auth_headers_for(user)
        }.to change(MenuReport, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to match({
          id: MenuReport.last.id,
          genre_name: genre.name,
          noodle_name: noodle.name,
          soup_name: soup.name,
          menu: {
            id: menu.id,
            name: menu.name,
            genre_name: genre.name,
            noodle_name: noodle.name,
            soup_name: soup.name,
            image_url: a_string_starting_with('http')
          }
        })
      end

      it 'menu_genreが未設定の場合、menu_genreを作成する' do
        expect {
          post '/api/v1/menu_reports', params: params, headers: auth_headers_for(user)
        }.to change(MenuGenre, :count).by(1)

        expect(menu.reload.genre).to eq(genre)
      end

      it 'menu_genreが既に設定されている場合、上書きしない' do
        existing_genre = create(:genre)
        create(:menu_genre, menu: menu, genre: existing_genre)

        expect {
          post '/api/v1/menu_reports', params: params, headers: auth_headers_for(user)
        }.not_to change(MenuGenre, :count)

        expect(menu.reload.genre).to eq(existing_genre)
      end

      it '同じユーザーが同じメニューに2回作成しようとすると422を返す' do
        create(:menu_report, user: user, menu: menu, genre: genre, noodle: noodle, soup: soup)

        post '/api/v1/menu_reports', params: params, headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'メニューを新規作成する場合' do
      let(:params) do
        {
          menu: { shop_id: shop.id, name: '特製醤油ラーメン' },
          genre_id: genre.id,
          noodle_id: noodle.id,
          soup_id: soup.id
        }
      end

      it 'menuとmenu_reportを同時に作成できる' do
        expect {
          post '/api/v1/menu_reports', params: params, headers: auth_headers_for(user)
        }.to change(Menu, :count).by(1).and change(MenuReport, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json).to match({
          id: MenuReport.last.id,
          genre_name: genre.name,
          noodle_name: noodle.name,
          soup_name: soup.name,
          menu: {
            id: Menu.last.id,
            name: '特製醤油ラーメン',
            genre_name: genre.name,
            noodle_name: noodle.name,
            soup_name: soup.name,
            image_url: nil
          }
        })
      end
    end

    context 'menu_idとmenu{}の両方を指定した場合' do
      it '422を返す' do
        post '/api/v1/menu_reports', params: {
          menu_id: menu.id,
          menu: { shop_id: shop.id, name: '特製醤油ラーメン' },
          genre_id: genre.id,
          noodle_id: noodle.id,
          soup_id: soup.id
        }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        post '/api/v1/menu_reports', params: { menu_id: menu.id }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
