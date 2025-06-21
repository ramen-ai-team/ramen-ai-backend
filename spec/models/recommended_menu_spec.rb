require 'rails_helper'

RSpec.describe RecommendedMenu, type: :model do
  describe '#find_best_match' do
    let!(:genre) { create(:genre, name: '醤油') }
    let!(:noodle) { create(:noodle, name: '細麺') }
    let!(:soup) { create(:soup, name: '鶏ガラ') }

    context '完全一致するMenuが存在する場合' do
      let!(:menu) { create(:menu, :with_category, genre:, noodle:, soup:) }

      it '完全一致するMenuを返すこと' do
        menu_json = { "genre" => genre.name, "noodles" => noodle.name, "soups" => soup.name }
        recommended_menu = RecommendedMenu.new(menu_json)
        expect(recommended_menu.find_best_match).to eq menu
      end
    end

    context '完全一致するMenuが存在しない場合' do
      let!(:other_noodle) { create(:noodle) }
      let!(:menu) { create(:menu, :with_category, genre:, soup:) }

      it 'SoupとGenreが一致するMenuを返すこと' do
        menu_json = { "genre" => genre.name, "noodles" => other_noodle.name, "soups" => soup.name }
        recommended_menu = RecommendedMenu.new(menu_json)
        expect(recommended_menu.find_best_match).to eq menu
      end
    end

    context 'SoupとGenreが一致するMenuも存在しない場合' do
      let!(:other_noodle) { create(:noodle) }
      let!(:other_genre) { create(:genre) }
      let!(:menu) { create(:menu, :with_category, soup:) }

      it 'Soupが一致するMenuを返すこと' do
        menu_json = { "genre" => other_genre.name, "noodles" => other_noodle.name, "soups" => soup.name }
        recommended_menu = RecommendedMenu.new(menu_json)
        expect(recommended_menu.find_best_match).to eq menu
      end
    end

    context 'Menuが存在しない場合' do
      it 'nilを返すこと' do
        menu_json = { "genre" => genre.name, "noodles" => noodle.name, "soups" => soup.name }
        recommended_menu = RecommendedMenu.new(menu_json)
        expect(recommended_menu.find_best_match).to eq nil
      end
    end
  end
end
