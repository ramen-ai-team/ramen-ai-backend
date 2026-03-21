class MenuReportCreationService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      menu = resolve_menu!
      menu_report = MenuReport.create!(
        user: @user,
        menu: menu,
        genre_id: @params[:genre_id],
        noodle_id: @params[:noodle_id],
        soup_id: @params[:soup_id]
      )
      attach_images(menu_report)
      backfill_menu_associations(menu_report)
      menu_report
    end
  end

  private

  def resolve_menu!
    if @params[:menu_id].present? && @params[:menu].present?
      raise ArgumentError, "menu_id と menu は同時に指定できません"
    elsif @params[:menu_id].present?
      Menu.find(@params[:menu_id])
    elsif @params[:menu].present?
      Menu.create!(@params[:menu].permit(:shop_id, :name))
    else
      raise ArgumentError, "menu_id または menu が必要です"
    end
  end

  def attach_images(menu_report)
    return unless @params[:images].present?

    @params[:images].each { |image| menu_report.images.attach(image) }
  end

  def backfill_menu_associations(menu_report)
    menu = menu_report.menu

    if menu_report.genre && menu.menu_genre.nil?
      menu.create_menu_genre!(genre: menu_report.genre)
    end
    if menu_report.noodle && menu.menu_noodle.nil?
      menu.create_menu_noodle!(noodle: menu_report.noodle)
    end
    if menu_report.soup && menu.menu_soup.nil?
      menu.create_menu_soup!(soup: menu_report.soup)
    end
  end
end
