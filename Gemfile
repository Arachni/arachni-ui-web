source 'http://rubygems.org'

gem 'rails', '4.0.0.beta1'

gem 'thin'

gem 'sqlite3'

gem 'jquery-rails', '2.1.4'
gem 'turbolinks'
gem 'jquery-turbolinks'

gem 'bootstrap-sass', '>= 2.3.0.0'

gem 'rdiscount'

gem 'simple_form', github: 'plataformatec/simple_form'
gem 'devise',      github: 'idl3/devise', branch: 'rails4'
gem 'kaminari'
gem 'cancan', '>= 1.6.8'
gem 'rolify', '>= 3.1.0'

group :development do
    #gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :assets do
    gem 'sass-rails',   github: 'rails/sass-rails'
    gem 'coffee-rails', github: 'rails/coffee-rails'

    gem 'uglifier', '>= 1.0.3'
    gem 'libv8',    '~> 3.11.8'
    gem 'therubyracer'
end

group :test do
    gem 'factory_girl'
    gem 'capybara',         '>= 1.1.2'
    gem 'cucumber-rails',   '>= 1.3.0', require: false
    gem 'database_cleaner', '>= 0.8.0'
    gem 'launchy',          '>= 2.2.0'
    gem 'machinist'
end

#gem "rspec-rails", ">= 2.11.0", group: [:development, :test]

gem 'arachni-rpc-em', git: 'git://github.com/Arachni/arachni-rpc-em.git'

if File.exist?( p = File.dirname( __FILE__ ) + '/../arachni' )
    gem 'arachni', git: "#{p}/.git", branch: 'experimental'
else
    gem 'arachni', github: 'Arachni/arachni', branch: 'experimental'
end
