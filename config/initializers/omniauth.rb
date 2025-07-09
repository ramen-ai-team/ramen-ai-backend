# Google OAuth credentials need to be configured
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.gcp[:oauth_client_id], Rails.application.credentials.gcp[:oauth_client_secret], {
    scope: "openid,profile,email",
    prompt: "select_account",
    image_aspect_ratio: "square",
    image_size: 50
  }
end
