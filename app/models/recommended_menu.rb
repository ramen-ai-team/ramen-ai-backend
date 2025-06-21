class RecommendedMenu
  def initialize(menu_json)
    @genre_name = menu_json["genre"]
    @noodle_name = menu_json["noodles"]
    @soup_name = menu_json["soups"]
  end

  def find_best_match
    # 完全一致するMenuを検索
    menu = Menu.joins(:soup, :genre, :noodle)
             .where(soups: { id: soup.id },
                    genres: { id: genre.id },
                    noodles: { id: noodle.id })
             .first

    return menu if menu

    # SoupとGenreが一致するMenuを検索
    menu = Menu.joins(:soup, :genre)
             .where(soups: { id: soup.id },
                    genres: { id: genre.id })
             .first

    return menu if menu

    # Soupが一致するMenuを検索
    menu = Menu.joins(:soup)
             .where(soups: { id: soup.id })
             .first

    menu
  end

  private

  attr_reader :genre, :noodle, :soup

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
