# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path( '../../config/environment', __FILE__ )
require 'rspec/rails'
require 'rspec/autorun'

require 'capybara/rspec'
require 'capybara/rails'

require 'factory_bot'
require 'database_cleaner'

require 'faker'

require 'arachni'
require 'arachni/processes'
require 'arachni/processes/helpers'

Dir[Rails.root.join( 'spec/{support,factories}/**/*.rb' )].each { |f| require f }

RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    config.before( :all ) do
        killall
        Arachni::Options.reset
    end

    config.after( :suite ) do
        killall
    end

    config.include ValidUserHelper, type: :controller
    config.include ValidUserRequestHelper, type: :request

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered                = true
    config.color                                           = true
    config.add_formatter :documentation

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures                 = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order                                      = 'random'
end
