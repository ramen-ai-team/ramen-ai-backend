class Api::V1::Admin::MenusController < Api::V1::Admin::ApplicationController
  before_action :set_menu, only: [:show, :update, :destroy]

  def index
    @menus = Menu.includes(:genre, :noodle, :soup, :shop).with_attached_image.all
    render json: @menus.as_json(
      include: [:shop, :genre, :soup, :noodle],
      methods: [:image_url]
    )
  end

  def show
    render json: @menu.as_json(
      include: [:shop, :genre, :soup, :noodle],
      methods: [:image_url]
    )
  end

  def create
    @menu = Menu.new(menu_params.slice(:name, :shop_id, :image))

    if @menu.save
      create_associations
      render json: @menu.as_json(
        include: [:shop, :genre, :soup, :noodle],
        methods: [:image_url]
      ), status: :created
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(menu_params.slice(:name, :shop_id, :image))
      update_associations
      render json: @menu.as_json(
        include: [:shop, :genre, :soup, :noodle],
        methods: [:image_url]
      )
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy
    render json: { message: "Menu deleted successfully" }
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :shop_id, :genre_id, :soup_id, :noodle_id, :image)
  end

  def create_associations
    create_menu_genre if params[:menu][:genre_id].present?
    create_menu_soup if params[:menu][:soup_id].present?
    create_menu_noodle if params[:menu][:noodle_id].present?
  end

  def update_associations
    update_menu_genre if params[:menu][:genre_id].present?
    update_menu_soup if params[:menu][:soup_id].present?
    update_menu_noodle if params[:menu][:noodle_id].present?
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
