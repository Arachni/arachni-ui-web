source 'https://rubygems.org'

gem 'rails', '6.0.0'

# Web server.
gem 'puma'

# SQLite DB (Default)
gem 'sqlite3'

# Postgres DB (Optional)
gem 'pg'#, '1.1.2'

# JavaScript support framework.
gem 'jquery-rails'#, '2.1.4'

# UI/CSS framework.
gem 'bootstrap-sass', '2.3.1.0'

# Markdown to HTML conversion.
gem 'kramdown'

# HTML form helper.
gem 'simple_form'

# User management/authentication.
gem "devise"#, "~> 3.5.1"

# User authorization management.
gem 'cancancan'#, '~> 1.6.10'

# User role management.
gem 'rolify', '~> 4.0.0'

# Pagination helper.
gem 'kaminari'

gem 'loofah'

# Required for MS Windows.
gem 'tzinfo-data'

group :development, :test do
    # Test framework.
    gem 'rspec-rails', '>= 2.11.0'
    gem 'factory_bot'
    gem 'listen'
end

group :assets do
    # Sass CSS preprocessor.
    gem 'sass-rails'#, '~> 4.0.0'

    # CoffeeScript JavaScript preprocessor, stick with '1.8.0' for Windows
    # compat.
    gem 'coffee-script-source', '1.8.0'
    gem 'coffee-rails'#, '~> 4.0.0'

    # JavaScript compression.
    gem 'uglifier', '~> 2.7.2'

    gem 'execjs'
    gem 'therubyracer', platforms: :ruby
end

group :test do
    # Browser simulator.
    gem 'capybara',         '>= 1.1.2'

    # BDD for Rails.
    gem 'cucumber-rails',   '>= 1.3.0', require: false

    # Does what its name suggests.
    gem 'database_cleaner', '>= 0.8.0'

    # Saves and launches the last failing webapp page.
    gem 'launchy',          '>= 2.2.0'

    # Sample values for model attributes.
    gem 'faker'
end

gem 'arachni'
