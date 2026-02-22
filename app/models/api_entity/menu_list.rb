module ApiEntity
  class MenuList
    include ::ActiveModel::Serializers::JSON

    attr_reader :menus

    def initialize(menus:)
      @menus = menus.map do |menu|
        ApiEntity::Menu.new(menu:)
      end
    end

    # デバッグ: どのメソッドが呼ばれているか確認
    def to_json(options = nil)
      raise "DEBUG: MenuList#to_json called!"
    end

    def as_json(options = nil)
      raise "DEBUG: MenuList#as_json called!"
    end

    private

    def attribute_names_for_serialization = %i[menus]
  end
end
