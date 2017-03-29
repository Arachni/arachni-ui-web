source 'https://rubygems.org'

gem 'rails', '4.2.5.1'

# Web server.
gem 'puma'

# SQLite DB (Default)
gem 'sqlite3'

# Postgres DB (Optional)
gem 'pg'

platforms :jruby do
    # Bunch of bundled DB adaptors for use when on JRuby.
    gem 'activerecord-jdbc-adapter'
    gem 'jdbc-postgres'
    gem 'jdbc-sqlite3'
end

# JavaScript support framework.
gem 'jquery-rails', '2.1.4'

# UI/CSS framework.
gem 'bootstrap-sass', '2.3.1.0'

# Markdown to HTML conversion.
gem 'kramdown'

# HTML form helper.
gem 'simple_form', '~> 3.0.1'

# User management/authentication.
gem "devise", "~> 3.5.1"

# User authorization management.
gem 'cancan', '~> 1.6.10'

# User role management.
gem 'rolify', '~> 4.0.0'

# Pagination helper.
gem 'kaminari'

gem 'loofah'

# Required for MS Windows.
gem 'tzinfo-data'

group :development do
    # Model factory.
    gem 'factory_girl_rails'
end

group :development, :test do
    # Test framework.
    gem 'rspec-rails', '>= 2.11.0'
end

group :assets do
    # Sass CSS preprocessor.
    gem 'sass-rails', '~> 4.0.0'

    # CoffeeScript JavaScript preprocessor, stick with '1.8.0' for Windows
    # compat.
    gem 'coffee-script-source', '1.8.0'
    gem 'coffee-rails', '~> 4.0.0'

    # JavaScript compression.
    gem 'uglifier', '~> 2.7.2'

    # JavaScript interpreters.
    gem 'therubyrhino', platform: 'jruby'
    gem 'libv8',    '~> 3.16.14.11', platform: 'ruby'

    # JavaScript interpreter wrapper.
    gem 'therubyracer', platform: 'ruby'
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

    # Model factory.
    gem 'factory_girl'

    # Sample values for model attributes.
    gem 'faker'
end

gem 'arachni'
