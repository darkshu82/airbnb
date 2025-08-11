source "https://rubygems.org"

gem "bootsnap", require: false

gem "devise", "~> 4.9", ">= 4.9.4"

gem "faker"

gem "image_processing", ">= 1.2"

gem "importmap-rails"

gem "jbuilder"

gem "money-rails", "~> 1.7"

gem "pg", "~> 1.1"

gem "propshaft"

gem "puma", ">= 5.0"

gem "rails", "~> 8.0.2"

gem "stimulus-rails"

gem "tailwindcss-rails"

gem "turbo-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
