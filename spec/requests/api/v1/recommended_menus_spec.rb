require 'rails_helper'

RSpec.describe Api::V1::RecommendedMenusController, type: :request do
  describe 'POST /api/v1/recommended_menus' do
    it 'returns a recommended menu based on select_menu_ids' do
      stub_gemini_token
      stub_gemini_recommended_ramen
      # 例としてselect_menu_idsを1と2とする
      select_menu_ids = [1, 2]
      post '/api/v1/recommended_menus', params: { select_menu_ids: select_menu_ids }
      expect(response).to have_http_status(:success)
      expect(json).to eq({
        recommended_menu: {
          reason: "魚介つけ麺や二郎系ラーメンなど、濃厚でインパクトのある味をお好みのようですので、同じく濃厚な「豚骨」スープのラーメンをおすすめします。特に食べ応えのある太麺との相性は抜群で、鶏ガラとはまた違ったクリーミーで深みのある味わいをお楽しみいただけます。",
          recommended_ramen: { genre: "ラーメン", noodles: "太麺", soups: "豚骨" }
        }
      })
    end

    it 'returns a recommended menu based on select_menu_ids & not_select_menu_ids' do
      stub_gemini_token
      stub_gemini_recommended_ramen
      # 例としてselect_menu_idsを1と2、not_select_menu_idsを3と4とする
      select_menu_ids = [1, 2]
      not_select_menu_ids = [3, 4]
      post '/api/v1/recommended_menus', params: { select_menu_ids: select_menu_ids, not_select_menu_ids: not_select_menu_ids }
      expect(response).to have_http_status(:success)
      expect(json).to eq({
        recommended_menu: {
          reason: "魚介つけ麺や二郎系ラーメンなど、濃厚でインパクトのある味をお好みのようですので、同じく濃厚な「豚骨」スープのラーメンをおすすめします。特に食べ応えのある太麺との相性は抜群で、鶏ガラとはまた違ったクリーミーで深みのある味わいをお楽しみいただけます。",
          recommended_ramen: { genre: "ラーメン", noodles: "太麺", soups: "豚骨" }
        }
      })
    end

    it 'returns an error if select_menu_ids is missing' do
      post '/api/v1/recommended_menus', params: {}
      expect(response).to have_http_status(:bad_request)
      expect(json).to eq({
        error: "select_menu_idsが必要です"
      })
    end
  end
end
