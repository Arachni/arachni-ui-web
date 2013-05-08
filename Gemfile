source 'http://rubygems.org'

gem 'rails', '4.0.0.beta1'

# Web server.
gem 'thin'

# DB
gem 'sqlite3'

# JavaScript support framework.
gem 'jquery-rails', '2.1.4'

# Uses AJAX requests for hyperlinks.
gem 'turbolinks'
gem 'jquery-turbolinks'

# UI/CSS framework.
gem 'bootstrap-sass', '2.3.1.0'

# Markdown to HTML conversion.
gem 'rdiscount'

# HTML form helper.
gem 'simple_form', '>= 3.0.0.beta1'

# User management/authentication.
gem 'devise',      github: 'idl3/devise', branch: 'rails4'

# User authorization management.
gem 'cancan', '>= 1.6.8'

# User role management.
gem 'rolify', '>= 3.1.0'

# Pagination helper.
gem 'kaminari'

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
    gem 'sass-rails',   '4.0.0.beta1'

    # CoffeeScript JavaScript preprocessor.
    gem 'coffee-rails', '4.0.0.beta1'

    # JavaScript compression.
    gem 'uglifier', '>= 1.0.3'

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

# The Arachni Framework.
if File.exist?( p = File.dirname( __FILE__ ) + '/../arachni-rpc-em' )
    gem 'arachni-rpc-em', path: p
else
    gem 'arachni-rpc-em', github: 'Arachni/arachni-rpc-em'
end

# The Arachni Framework.
if File.exist?( p = File.dirname( __FILE__ ) + '/../arachni' )
    gem 'arachni', path: p
else
    gem 'arachni', github: 'Arachni/arachni', branch: 'experimental'
end
