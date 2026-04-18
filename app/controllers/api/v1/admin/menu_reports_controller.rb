class Api::V1::Admin::MenuReportsController < Api::V1::Admin::ApplicationController
  def index
    pagy, @menu_reports = pagy(
      MenuReport.includes(:user, :menu, :genre, :noodle, :soup).with_attached_images.order(created_at: :desc)
    )
    pagy_headers_merge(pagy)
    render json: @menu_reports.as_json(
      only: [:id, :created_at],
      include: {
        user: { only: [:id, :name, :email] },
        menu: { only: [:id, :name], include: { shop: { only: [:id, :name] } } },
        genre: { only: [:id, :name] },
        noodle: { only: [:id, :name] },
        soup: { only: [:id, :name] }
      },
      methods: [:image_urls]
    )
  end
end
