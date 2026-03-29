module ApiEntity
  class MenuReportList
    include ::ActiveModel::Serializers::JSON

    def initialize(menu_reports:)
      @menu_reports = menu_reports
    end

    private

    def attribute_names_for_serialization = %i[menu_reports]

    def menu_reports
      @menu_reports.map { |mr| ApiEntity::MenuReport.new(menu_report: mr) }
    end
  end
end
