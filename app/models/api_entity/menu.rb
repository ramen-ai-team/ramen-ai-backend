module ApiEntity
  class Menu
    include ::ActiveModel::Serializers::JSON

    delegate :id, :name, to: :@menu

    def initialize(menu:)
      @menu = menu
    end

    private

    def attribute_names_for_serialization = %i[id name genre_name noodle_name soup_name image_url]

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
      puts "=" * 80
      puts "[DEBUG] ApiEntity::Menu#image_url called for menu_id=#{@menu.id}"
      puts "=" * 80
      url = @menu.image_url
      puts "[DEBUG] ApiEntity::Menu#image_url returned: #{url}"
      puts "=" * 80
      url
    end
  end
end
