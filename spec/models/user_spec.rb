require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires email' do
      user = User.new(name: 'Test User', provider: 'google', uid: '123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires name' do
      user = User.new(email: 'test@example.com', provider: 'google', uid: '123')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'requires provider' do
      user = User.new(email: 'test@example.com', name: 'Test User', uid: '123')
      expect(user).not_to be_valid
      expect(user.errors[:provider]).to include("can't be blank")
    end

    it 'requires uid' do
      user = User.new(email: 'test@example.com', name: 'Test User', provider: 'google')
      expect(user).not_to be_valid
      expect(user.errors[:uid]).to include("can't be blank")
    end

    it 'requires unique email' do
      User.create!(email: 'test@example.com', name: 'Test User', provider: 'google', uid: '123')
      user = User.new(email: 'test@example.com', name: 'Another User', provider: 'google', uid: '456')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'requires unique uid per provider' do
      User.create!(email: 'test1@example.com', name: 'Test User 1', provider: 'google', uid: '123')
      user = User.new(email: 'test2@example.com', name: 'Test User 2', provider: 'google', uid: '123')
      expect(user).not_to be_valid
      expect(user.errors[:uid]).to include("has already been taken")
    end

    it 'allows same uid for different providers' do
      User.create!(email: 'test1@example.com', name: 'Test User 1', provider: 'google', uid: '123')
      user = User.new(email: 'test2@example.com', name: 'Test User 2', provider: 'facebook', uid: '123')
      expect(user).to be_valid
    end
  end

  describe '.from_omniauth' do
    let(:auth_hash) do
      auth_klass = Data.define(:provider, :uid, :info)
      info_klass = Data.define(:email, :name, :image)
      auth_klass.new(
        provider: 'google',
        uid: '123456789',
        info: info_klass.new(
          email: 'test@example.com',
          name: 'Test User',
          image: 'https://example.com/image.jpg'
        )
      )
    end

    it 'creates a new user from omniauth hash' do
      expect {
        User.from_omniauth(auth_hash)
      }.to change(User, :count).by(1)
    end

    it 'returns existing user if already exists' do
      user = User.create!(
        email: 'test@example.com',
        name: 'Test User',
        provider: 'google',
        uid: '123456789'
      )

      expect(User.from_omniauth(auth_hash)).to eq(user)
    end

    it 'sets user attributes from auth hash' do
      user = User.from_omniauth(auth_hash)
      expect(user.email).to eq('test@example.com')
      expect(user.name).to eq('Test User')
      expect(user.provider).to eq('google')
      expect(user.uid).to eq('123456789')
      expect(user.image).to eq('https://example.com/image.jpg')
    end
  end
end
