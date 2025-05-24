require "pagy/extras/headers"

class ApplicationController < ActionController::API
  def top
    render json: { message: "Welcome to the API!" }
  end
end
