class Api::V1::Admin::UsersController < Api::V1::Admin::ApplicationController
  def index
    pagy, @users = pagy(User.order(:id))
    pagy_headers_merge(pagy)
    render json: @users
  end
end
