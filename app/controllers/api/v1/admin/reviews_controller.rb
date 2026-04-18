class Api::V1::Admin::ReviewsController < Api::V1::Admin::ApplicationController
  def index
    pagy, @reviews = pagy(
      Review.includes(:user, menu: :shop).order(created_at: :desc)
    )
    pagy_headers_merge(pagy)
    render json: @reviews.as_json(
      only: [:id, :rating, :comment, :visited_at, :created_at],
      include: {
        user: { only: [:id, :name, :email] },
        menu: { only: [:id, :name], include: { shop: { only: [:id, :name] } } }
      }
    )
  end
end
