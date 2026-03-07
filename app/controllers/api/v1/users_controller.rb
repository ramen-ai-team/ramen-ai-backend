class Api::V1::UsersController < Api::V1::ApplicationController
  def current
    render json: {
      id: current_user.id,
      name: current_user.name,
      email: current_user.email,
      image: current_user.image
    }
  end
end
