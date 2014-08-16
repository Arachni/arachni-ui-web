source 'https://rubygems.org'

gem 'rails', '4.1.4'

gem 'psych'

# Web server.
gem 'thin'

# SQLite DB (Default)
gem 'sqlite3'

# Postgres DB (Optional)
# gem 'pg'

# JavaScript support framework.
gem 'jquery-rails', '2.1.4'

# UI/CSS framework.
gem 'bootstrap-sass', '2.3.1.0'

# Markdown to HTML conversion.
gem 'github-markdown'

# HTML form helper.
gem 'simple_form', '~> 3.0.1'

# User management/authentication.
gem "devise", "~> 3.2.2"

# User authorization management.
gem 'cancan', '~> 1.6.10'

# User role management.
gem 'rolify', '~> 3.4.0'

# Pagination helper.
gem 'kaminari'

gem 'loofah'

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

    # CoffeeScript JavaScript preprocessor.
    gem 'coffee-rails', '~> 4.0.0'

    # JavaScript compression.
    gem 'uglifier', '~> 1.0.3'

    # JavaScript interpreter.
    gem 'libv8',    '~> 3.11.8'
    # JavaScript interpreter wrapper.
    gem 'therubyracer'
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

if RbConfig::CONFIG['host_os'].include? 'darwin'
    gem 'arachni-rpc', path: File.dirname( __FILE__ ) + '/../arachni-rpc-v0.2'
    gem 'arachni',     path: File.dirname( __FILE__ ) + '/../arachni'
else
    gem 'arachni-rpc', path: '/home/zapotek/workspace/arachni-rpc-v0.2'
    gem 'arachni',     path: '/home/zapotek/workspace/arachni-v0.5'
end
