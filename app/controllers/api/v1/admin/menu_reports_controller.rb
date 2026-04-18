class Api::V1::Admin::MenuReportsController < Api::V1::Admin::ApplicationController
  def index
    user = User.find(params[:user_id])
    pagy, @menu_reports = pagy(
      user.menu_reports.includes(:genre, :noodle, :soup, menu: [:shop, :reviews]).with_attached_images.order(created_at: :desc)
    )
    pagy_headers_merge(pagy)
    render json: @menu_reports.as_json(
      only: [:id, :created_at],
      include: {
        menu: {
          only: [:id, :name],
          include: {
            shop: { only: [:id, :name] },
            reviews: { only: [:id, :rating, :comment, :visited_at] }
          }
        },
        genre: { only: [:id, :name] },
        noodle: { only: [:id, :name] },
        soup: { only: [:id, :name] }
      },
      methods: [:image_urls]
    )
  end
end
