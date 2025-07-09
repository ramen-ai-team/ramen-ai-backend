class Api::V1::Admin::NoodlesController < Api::V1::Admin::ApplicationController
  def index
    @noodles = Noodle.all
    render json: @noodles
  end
end
