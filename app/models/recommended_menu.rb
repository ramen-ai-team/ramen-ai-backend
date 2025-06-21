class RecommendedMenu
  def initialize(menu_json)
    @genre_name = menu_json["genre"]
    @noodle_name = menu_json["noodles"]
    @soup_name = menu_json["soups"]
  end

  def find_best_match
    menus.first
  end

  private

  attr_reader :genre, :noodle, :soup

  def menus
    return @menus if defined?(@menus)

    # 完全一致するMenuを検索
    menus = Menu.joins(:soup, :genre, :noodle)
             .where(soups: { id: soup.id },
                    genres: { id: genre.id },
                    noodles: { id: noodle.id })

    return @menus = memus if menus.exists?

    # SoupとGenreが一致するMenuを検索
    menus = Menu.joins(:soup, :genre)
             .where(soups: { id: soup.id },
                    genres: { id: genre.id })

    return @menus = menus if menus.exists?

    # Soupが一致するMenuを検索
    menus = Menu.joins(:soup)
             .where(soups: { id: soup.id })

    @menus = menus if menus.exists?
    @menus ||= Menu.none
  end

  def genre
    @genre ||= Genre.find_by!(name: @genre_name)
  end

  def noodle
    @noodle ||= Noodle.find_by!(name: @noodle_name)
  end

  def soup
    @soup ||= Soup.find_by!(name: @soup_name)
  end
end
