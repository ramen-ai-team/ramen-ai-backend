require 'pagy/extras/headers'

class ApplicationController < ActionController::API
  include Pagy::Backend

  def top
    render json: { message: 'Welcome to the API!' }
  end
end
