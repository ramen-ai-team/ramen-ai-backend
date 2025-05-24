module Api
  module V1
    class BaseController < ::ApplicationController
      include Pagy::Backend
    end
  end
end
