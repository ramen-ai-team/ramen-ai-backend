class Api::V1::Admin::GenresController < Api::V1::Admin::ApplicationController
  def index
    pagy, @genres = pagy(Genre.all)
    pagy_headers_merge(pagy)
    render json: @genres
  end
end
