require 'rails_helper'

RSpec.describe Api::V1::RecommendedMenusController, type: :request do
  describe 'POST /api/v1/recommended_menus' do
    it 'returns a recommended menu based on menu_ids' do
      # 例としてmenu_idsを1と2とする
      menu_ids = [1, 2]
      post '/api/v1/recommended_menus', params: { menu_ids: menu_ids }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('recommended_menu')
    end

    it 'returns an error if menu_ids is missing' do
      post '/api/v1/recommended_menus', params: {}
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('error')
    end
  end
end
