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

    it 'requires unique google_id when present' do
      User.create!(email: 'test1@example.com', name: 'Test User 1', provider: 'google', uid: '123', google_id: 'google_123')
      user = User.new(email: 'test2@example.com', name: 'Test User 2', provider: 'google', uid: '456', google_id: 'google_123')
      expect(user).not_to be_valid
      expect(user.errors[:google_id]).to include("has already been taken")
    end

    it 'allows nil google_id' do
      user = User.new(email: 'test@example.com', name: 'Test User', provider: 'google', uid: '123', google_id: nil)
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

  describe '#generate_jwt_token' do
    let(:user) { User.create!(email: 'test@example.com', name: 'Test User', provider: 'google', uid: '123') }
    let(:secret_key) { Rails.application.secret_key_base }

    it 'generates a valid JWT token' do
      token = user.generate_jwt_token
      expect(token).to be_present

      # JWT tokenをデコードして検証
      decoded_token = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
      payload = decoded_token[0]

      expect(payload['user_id']).to eq(user.id)
      expect(payload['exp']).to be > Time.current.to_i
      expect(payload['iat']).to be <= Time.current.to_i
    end

    it 'sets expiration to 7 days from now' do
      token = user.generate_jwt_token
      decoded_token = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
      payload = decoded_token[0]

      expected_exp = 7.days.from_now.to_i
      expect(payload['exp']).to be_within(5).of(expected_exp)
    end
  end

  describe '.find_or_create_from_google' do
    let(:google_data) do
      {
        google_id: 'google_123',
        email: 'user@example.com',
        name: 'Test User',
        picture: 'https://example.com/photo.jpg',
        email_verified: true
      }
    end

    context 'when user with google_id exists' do
      let!(:existing_user) do
        User.create!(
          email: 'user@example.com',
          name: 'Old Name',
          provider: 'google',
          uid: 'google_123',
          google_id: 'google_123',
          image: 'old_image.jpg'
        )
      end

      it 'updates existing user data' do
        user = User.find_or_create_from_google(google_data)

        expect(user).to eq(existing_user)
        expect(user.name).to eq('Test User')
        expect(user.image).to eq('https://example.com/photo.jpg')
      end

      it 'does not create new user' do
        expect {
          User.find_or_create_from_google(google_data)
        }.not_to change(User, :count)
      end
    end

    context 'when user with email exists but no google_id' do
      let!(:existing_user) do
        User.create!(
          email: 'user@example.com',
          name: 'Existing User',
          provider: 'other',
          uid: 'other_123'
        )
      end

      it 'links google_id to existing user' do
        user = User.find_or_create_from_google(google_data)

        expect(user).to eq(existing_user)
        expect(user.google_id).to eq('google_123')
      end

      it 'does not create new user' do
        expect {
          User.find_or_create_from_google(google_data)
        }.not_to change(User, :count)
      end
    end

    context 'when user does not exist' do
      it 'creates new user with Google data' do
        expect {
          User.find_or_create_from_google(google_data)
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.google_id).to eq('google_123')
        expect(user.email).to eq('user@example.com')
        expect(user.name).to eq('Test User')
        expect(user.image).to eq('https://example.com/photo.jpg')
        expect(user.email_verified).to be true
        expect(user.provider).to eq('google')
        expect(user.uid).to eq('google_123')
      end
    end

    context 'with invalid data' do
      let(:invalid_google_data) { google_data.merge(email: nil) }

      it 'raises validation error' do
        expect {
          User.find_or_create_from_google(invalid_google_data)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
