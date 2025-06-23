class Api::V1::Admin::SoupsController < Api::V1::Admin::ApplicationController
  def index
    @soups = Soup.all
    render json: @soups
  end
end