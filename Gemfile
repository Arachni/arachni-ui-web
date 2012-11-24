source 'https://rubygems.org'
gem 'rails', '3.2.8'
gem 'sqlite3'

group :assets do
    gem 'sass-rails',   '~> 3.2.3'
    gem 'coffee-rails', '~> 3.2.1'
    gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem "puma", ">= 1.4.1", group: [:development, :test]
gem "rspec-rails", ">= 2.11.0", group: [:development, :test]
gem "capybara", ">= 1.1.2", group: :test
gem "cucumber-rails", ">= 1.3.0", group: :test, require: false
gem "database_cleaner", ">= 0.8.0", group: :test
gem "launchy", ">= 2.1.0", group: :test
gem "machinist", group: :test
gem "bootstrap-sass", ">= 2.2.1.1"
gem "simple_form"
gem "devise", ">= 2.1.2"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.1.0"
gem "therubyracer", group: :assets, platform: :ruby

gem 'rails-footnotes', '>= 3.7.5.rc4', group: :development

gem 'arachni-rpc-em', '0.1.3dev', git: 'git://github.com/Arachni/arachni-rpc-em.git'

if File.exist?( p = File.dirname( __FILE__ ) + '/../arachni' )
    gem 'arachni', git: "#{p}/.git", branch: 'no-webui'
else
    gem 'arachni', github: 'Arachni/arachni', branch: 'no-webui'
end
