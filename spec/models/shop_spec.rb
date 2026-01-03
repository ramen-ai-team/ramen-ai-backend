require 'rails_helper'

RSpec.describe Shop, type: :model do
  describe 'validations' do
    describe 'presence validations' do
      it 'is invalid without name' do
        shop = build(:shop, name: nil)
        expect(shop).not_to be_valid
        expect(shop.errors[:name]).to include("can't be blank")
      end

      it 'is invalid without address' do
        shop = build(:shop, address: nil)
        expect(shop).not_to be_valid
        expect(shop.errors[:address]).to include("can't be blank")
      end

      it 'is invalid without google_map_url' do
        shop = build(:shop, google_map_url: nil)
        expect(shop).not_to be_valid
        expect(shop.errors[:google_map_url]).to include("can't be blank")
      end
    end

    describe 'length validations' do
      it 'is invalid with name longer than 100 characters' do
        shop = build(:shop, name: 'a' * 101)
        expect(shop).not_to be_valid
        expect(shop.errors[:name]).to include('is too long (maximum is 100 characters)')
      end

      it 'is invalid with address longer than 255 characters' do
        shop = build(:shop, address: 'a' * 256)
        expect(shop).not_to be_valid
        expect(shop.errors[:address]).to include('is too long (maximum is 255 characters)')
      end

      it 'is invalid with google_map_url longer than 255 characters' do
        shop = build(:shop, google_map_url: 'https://maps.app.goo.gl/' + 'a' * 256)
        expect(shop).not_to be_valid
        expect(shop.errors[:google_map_url]).to include('is too long (maximum is 255 characters)')
      end
    end

    describe 'google_map_url uniqueness' do
      let!(:existing_shop) { create(:shop, google_map_url: 'https://maps.app.goo.gl/unique123') }

      it 'validates uniqueness of google_map_url' do
        duplicate_shop = build(:shop, google_map_url: 'https://maps.app.goo.gl/unique123')
        expect(duplicate_shop).not_to be_valid
        expect(duplicate_shop.errors[:google_map_url]).to include('has already been taken')
      end

      it 'allows different google_map_url' do
        different_shop = build(:shop, google_map_url: 'https://maps.app.goo.gl/unique456')
        expect(different_shop).to be_valid
      end
    end

    describe 'google_map_url format' do
      it 'is valid with Google Maps short URL' do
        shop = build(:shop, google_map_url: 'https://maps.app.goo.gl/abc123')
        expect(shop).to be_valid
      end

      it 'is invalid with full Google Maps URL' do
        shop = build(:shop, google_map_url: 'https://www.google.com/maps/place/Shop/@35.6812,139.7671')
        expect(shop).not_to be_valid
        expect(shop.errors[:google_map_url]).to include('は「https://maps.app.goo.gl/」から始まるGoogle Map URLにしてください')
      end

      it 'is invalid with non-Google Maps URL' do
        shop = build(:shop, google_map_url: 'https://example.com')
        expect(shop).not_to be_valid
        expect(shop.errors[:google_map_url]).to include('は「https://maps.app.goo.gl/」から始まるGoogle Map URLにしてください')
      end

      it 'is invalid with empty string' do
        shop = build(:shop, google_map_url: '')
        expect(shop).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it 'has many menus' do
      shop = create(:shop)
      menu1 = create(:menu, shop: shop)
      menu2 = create(:menu, shop: shop)

      expect(shop.menus).to include(menu1, menu2)
    end

    it 'destroys associated menus when shop is destroyed' do
      shop = create(:shop)
      menu = create(:menu, shop: shop)

      expect { shop.destroy }.to change(Menu, :count).by(-1)
    end
  end
end
