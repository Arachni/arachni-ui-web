Rails.application.config.generators do |g|
    g.test_framework :rspec, fixture: true
    g.fixture_replacement :factory_bot, dir: 'spec/factories'
end
