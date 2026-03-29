class Api::V1::Admin::NoodlesController < Api::V1::Admin::ApplicationController
  def index
    pagy, @noodles = pagy(Noodle.all)
    pagy_headers_merge(pagy)
    render json: @noodles
  end
end
