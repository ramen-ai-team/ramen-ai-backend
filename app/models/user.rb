class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :google_id, uniqueness: true, allow_nil: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.provider = auth.provider
      user.uid = auth.uid
      user.image = auth.info.image
    end
  end

  # Google認証用のメソッド
  def generate_jwt_token
    payload = {
      user_id: id,
      exp: 7.days.from_now.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def self.find_or_create_from_google(google_data)
    # Google IDで検索
    user = find_by(google_id: google_data[:google_id])

    if user
      # 既存ユーザーの情報更新
      user.update!(
        name: google_data[:name],
        image: google_data[:picture]
      )
      return user
    end

    # メールアドレスで既存ユーザー確認
    existing_user = find_by(email: google_data[:email])
    if existing_user
      # 既存のメールアドレスにGoogle IDを紐付け
      existing_user.update!(google_id: google_data[:google_id])
      return existing_user
    end

    # 新規ユーザー作成
    create!(
      google_id: google_data[:google_id],
      email: google_data[:email],
      name: google_data[:name],
      image: google_data[:picture],
      email_verified: google_data[:email_verified],
      provider: 'google',
      uid: google_data[:google_id]
    )
  end
end
