module ApiEntity
  class MenuWithShop
    include ::ActiveModel::Serializers::JSON

    delegate :id, :name, to: :@menu

    def initialize(menu:)
      @menu = menu
    end

    private

    def attribute_names_for_serialization = %i[id name genre_name noodle_name soup_name image_url shop]

    def genre_name
      @menu.genre&.name
    end

    def noodle_name
      @menu.noodle&.name
    end

    def soup_name
      @menu.soup&.name
    end

    def image_url
      @menu.image_url
    end

    def shop
      ApiEntity::Shop.new(shop: @menu.shop)
    end
  end
end
