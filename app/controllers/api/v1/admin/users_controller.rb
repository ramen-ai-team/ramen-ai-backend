class Api::V1::Admin::UsersController < Api::V1::Admin::ApplicationController
  def index
    @users = User.order(:id)
    render json: @users
  end
end
