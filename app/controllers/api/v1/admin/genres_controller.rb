class Api::V1::Admin::GenresController < Api::V1::Admin::ApplicationController
  def index
    @genres = Genre.all
    render json: @genres
  end
end