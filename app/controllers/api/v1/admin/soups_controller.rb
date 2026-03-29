class Api::V1::Admin::SoupsController < Api::V1::Admin::ApplicationController
  def index
    pagy, @soups = pagy(Soup.all)
    pagy_headers_merge(pagy)
    render json: @soups
  end
end
