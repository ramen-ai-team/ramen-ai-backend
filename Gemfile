source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "mysql2", "~> 0.5"
gem "puma", ">= 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"

gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

gem "dotenv"

gem "pagy"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

gem "googleauth"

gem "google-cloud-storage"
gem "image_processing", ">= 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "webmock", require: false
end

group :development do
  gem "rails_best_practices"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rails-omakase", require: false

  gem "better_errors"
  gem "binding_of_caller"
end
