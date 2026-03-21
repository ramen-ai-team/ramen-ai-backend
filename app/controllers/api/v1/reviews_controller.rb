module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_menu
      before_action :set_review, only: [:update]

      def create
        review = current_user.reviews.build(review_params.merge(menu: @menu))
        if review.save
          render json: ApiEntity::Review.new(review:).to_json, status: :created
        else
          render json: ApiEntity::Errors.new(review.errors.full_messages).to_json, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: ApiEntity::Review.new(review: @review).to_json, status: :ok
        else
          render json: ApiEntity::Errors.new(@review.errors.full_messages).to_json, status: :unprocessable_entity
        end
      end

      private

      def set_menu
        @menu = Menu.find(params[:menu_id])
      end

      def set_review
        @review = current_user.reviews.find(params[:id])
      end

      def review_params
        params.permit(:rating, :comment, :visited_at)
      end
    end
  end
end
