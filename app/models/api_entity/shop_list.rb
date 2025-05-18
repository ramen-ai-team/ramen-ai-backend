module ApiEntity
  class ShopList
    include ::ActiveModel::Serializers::JSON

    attr_reader :shops

    def initialize(shops:)
      @shops = shops.map do |shop|
        ApiEntity::Shop.new(shop:)
      end
    end

    private

    def attribute_names_for_serialization = %i[shops]
  end
end
