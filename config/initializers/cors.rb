# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = case Rails.env
      when "production"
        ["https://ramen-ai-frontend.vercel.app", "https://ramen-ai-admin.vercel.app", "https://ramen-ni-ai-wo.vercel.app"]
      when "development"
        ["http://localhost:8081", "http://localhost:3001"]
      else
        []
      end
    origins allowed_origins
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
