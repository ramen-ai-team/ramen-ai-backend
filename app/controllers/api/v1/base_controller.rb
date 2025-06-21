module Api
  module V1
    class BaseController < ::ApplicationController
      include Pagy::Backend

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: { error: exception.message }, status: :not_found
      end
    end
  end
end
