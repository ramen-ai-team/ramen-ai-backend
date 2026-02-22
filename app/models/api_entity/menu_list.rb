module ApiEntity
  class MenuList
    include ::ActiveModel::Serializers::JSON

    attr_reader :menus

    def initialize(menus:)
      @menus = menus.map do |menu|
        ApiEntity::Menu.new(menu:)
      end
    end

    private

    def attribute_names_for_serialization = %i[menus]
  end
end
