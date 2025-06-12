require 'rails_helper'

RSpec.describe Api::V1::RecommendedMenusController, type: :request do
  describe 'POST /api/v1/recommended_menus' do
    it 'returns a recommended menu based on menu_ids' do
      stub_gemini_token
      stub_gemini_recommended_ramen
      # 例としてmenu_idsを1と2とする
      menu_ids = [1, 2]
      post '/api/v1/recommended_menus', params: { menu_ids: menu_ids }
      expect(response).to have_http_status(:success)
      expect(json).to eq({
        recommended_menu: {
          reason: "魚介つけ麺や二郎系ラーメンなど、濃厚でインパクトのある味をお好みのようですので、同じく濃厚な「豚骨」スープのラーメンをおすすめします。特に食べ応えのある太麺との相性は抜群で、鶏ガラとはまた違ったクリーミーで深みのある味わいをお楽しみいただけます。",
          recommended_ramen: { genre: "ラーメン", noodles: "太麺", soups: "豚骨" }
        }
      })
    end

    it 'returns an error if menu_ids is missing' do
      post '/api/v1/recommended_menus', params: {}
      expect(response).to have_http_status(:bad_request)
      expect(json).to eq({
        error: "menu_idsが必要です"
      })
    end
  end
end
