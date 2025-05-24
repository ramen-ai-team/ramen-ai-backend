require 'rails_helper'

RSpec.describe RandomMenusController, type: :request do
  describe 'GET /random_menus' do
    let!(:menu) { create(:menu, :with_category, name: '博多ラーメン', genre:, noodle:, soup:) }
    let!(:genre) { create(:genre, name: 'ラーメン') }
    let!(:noodle) { create(:noodle, name: '細麺') }
    let!(:soup) { create(:soup, name: '豚骨スープ') }

    it 'returns all menus' do
      get '/random_menus'
      expect(response.status).to eq 200
      expect(json).to eq({
        menus: [{
          id: menu.id,
          name: '博多ラーメン',
          genre_name: 'ラーメン',
          noodle_name: '細麺',
          soup_name: '豚骨スープ'
        }]
      })
    end
  end
end
