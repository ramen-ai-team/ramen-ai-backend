class Admin::ShopsController < Admin::ApplicationController
  before_action :set_shop, only: [:show, :edit, :update, :destroy]

  def index
    @shops = Shop.all
  end

  def show
  end

  def new
    @shop = Shop.new
  end

  def create
    @shop = Shop.new(shop_params)

    if @shop.save
      redirect_to admin_shop_path(@shop), notice: "ショップが正常に作成されました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @shop.update(shop_params)
      redirect_to admin_shop_path(@shop), notice: "ショップが正常に更新されました。"
    else
      render :edit
    end
  end

  def destroy
    @shop.destroy
    redirect_to admin_shops_path, notice: "ショップが正常に削除されました。"
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

  def shop_params
    params.require(:shop).permit(:name, :address, :google_map_url)
  end
end