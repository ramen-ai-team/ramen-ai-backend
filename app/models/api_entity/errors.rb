module ApiEntity
  class Errors
    include ::ActiveModel::Serializers::JSON

    def initialize(messages)
      @errors = Array(messages)
    end

    private

    def attribute_names_for_serialization = %i[errors]

    def errors
      @errors
    end
  end
end
