module ApiEntity
  class MenuReport
    include ::ActiveModel::Serializers::JSON

    delegate :id, :menu_id, :genre_id, :noodle_id, :soup_id, to: :@menu_report

    def initialize(menu_report:)
      @menu_report = menu_report
    end

    private

    def attribute_names_for_serialization = %i[id menu genre_name noodle_name soup_name]

    def menu
      ApiEntity::Menu.new(menu: @menu_report.menu)
    end

    def genre_name
      @menu_report.genre.name
    end

    def noodle_name
      @menu_report.noodle.name
    end

    def soup_name
      @menu_report.soup.name
    end

    def image_urls
      @menu_report.images.map(&:image_url)
    end
  end
end
