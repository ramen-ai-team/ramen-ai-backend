class Api::V1::Admin::ShopsController < Api::V1::Admin::ApplicationController
  before_action :set_shop, only: [:show, :update, :destroy]

  def index
    @shops = Shop.includes(:menus).all
    render json: @shops.as_json(
      include: {
        menus: {
          only: [:id, :name],
          methods: [:image_url]
        }
      }
    )
  end

  def show
    render json: @shop.as_json(
      include: {
        menus: {
          include: [:genre, :soup, :noodle, :menus],
          methods: [:image_url]
        }
      }
    )
  end

  def create
    @shop = Shop.new(shop_params)

    if @shop.save
      render json: @shop, status: :created
    else
      render json: { errors: @shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shop.update(shop_params)
      render json: @shop
    else
      render json: { errors: @shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy
    render json: { message: "Shop deleted successfully" }
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

  def shop_params
    params.require(:shop).permit(:name, :address, :google_map_url)
  end
end
