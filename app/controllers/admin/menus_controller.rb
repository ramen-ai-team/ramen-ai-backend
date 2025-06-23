class Admin::MenusController < Admin::ApplicationController
  before_action :set_menu, only: [:show, :edit, :update, :destroy]
  before_action :load_associations, only: [:new, :edit, :create, :update]

  def index
    @menus = Menu.includes(:shop, :genre, :soup, :noodle).all
  end

  def show
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      create_associations
      redirect_to admin_menu_path(@menu), notice: "メニューが正常に作成されました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @menu.update(menu_params)
      update_associations
      redirect_to admin_menu_path(@menu), notice: "メニューが正常に更新されました。"
    else
      render :edit
    end
  end

  def destroy
    @menu.destroy
    redirect_to admin_menus_path, notice: "メニューが正常に削除されました。"
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def load_associations
    @shops = Shop.all
    @genres = Genre.all
    @soups = Soup.all
    @noodles = Noodle.all
  end

  def menu_params
    params.require(:menu).permit(:name, :shop_id, :image, :genre_id, :soup_id, :noodle_id)
  end

  def create_associations
    create_menu_genre
    create_menu_soup
    create_menu_noodle
  end

  def update_associations
    update_menu_genre
    update_menu_soup
    update_menu_noodle
  end

  def create_menu_genre
    @menu.menu_genre&.destroy
    @menu.create_menu_genre(genre_id: params[:menu][:genre_id])
  end

  def create_menu_soup
    @menu.menu_soup&.destroy
    @menu.create_menu_soup(soup_id: params[:menu][:soup_id])
  end

  def create_menu_noodle
    @menu.menu_noodle&.destroy
    @menu.create_menu_noodle(noodle_id: params[:menu][:noodle_id])
  end

  def update_menu_genre
    if @menu.menu_genre
      @menu.menu_genre.update(genre_id: params[:menu][:genre_id])
    else
      @menu.create_menu_genre(genre_id: params[:menu][:genre_id])
    end
  end

  def update_menu_soup
    if @menu.menu_soup
      @menu.menu_soup.update(soup_id: params[:menu][:soup_id])
    else
      @menu.create_menu_soup(soup_id: params[:menu][:soup_id])
    end
  end

  def update_menu_noodle
    if @menu.menu_noodle
      @menu.menu_noodle.update(noodle_id: params[:menu][:noodle_id])
    else
      @menu.create_menu_noodle(noodle_id: params[:menu][:noodle_id])
    end
  end
end