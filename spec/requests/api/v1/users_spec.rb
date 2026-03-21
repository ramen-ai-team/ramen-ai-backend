require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'GET /api/v1/current_user' do
    let(:user) { create(:user) }

    context '認証済みの場合' do
      it 'ユーザー情報を返す' do
        get '/api/v1/current_user', headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json).to eq({
          id: user.id,
          name: user.name,
          email: user.email,
          image: user.image
        })
      end
    end

    context 'トークンなしの場合' do
      it '401を返す' do
        get '/api/v1/current_user'

        expect(response).to have_http_status(:unauthorized)
        expect(json[:errors]).to eq(['missing_token'])
      end
    end

    context '無効なトークンの場合' do
      it '401を返す' do
        get '/api/v1/current_user', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        expect(json[:errors]).to eq(['invalid_token'])
      end
    end
  end
end
