class Api::V1::ApplicationController < ApplicationController
  include JwtAuthenticable

  private

  def skip_authentication?
    action_name.in?(["google"]) && controller_name == "auth"
  end
end
