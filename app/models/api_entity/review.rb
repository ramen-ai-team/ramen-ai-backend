module ApiEntity
  class Review
    include ::ActiveModel::Serializers::JSON

    delegate :id, :menu_id, :rating, :comment, to: :@review

    def initialize(review:)
      @review = review
    end

    private

    def attribute_names_for_serialization = %i[id rating comment visited_at menu]

    def visited_at
      @review.visited_at.to_s
    end

    def menu
      ApiEntity::Menu.new(menu: @review.menu)
    end
  end
end
