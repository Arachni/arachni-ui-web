=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

require File.expand_path( '../boot', __FILE__ )

require 'rails/all'

if defined?( Bundler )
    # If you precompile assets before deploying to production, use this line
    Bundler.require( *Rails.groups( assets: %w(development test) ) )
    # If you want your assets lazily compiled in production, use this line
    # Bundler.require(:default, :assets, Rails.env)
end

module ArachniWebui

    class Application < Rails::Application

        # don't generate RSpec tests for views and helpers
        config.generators do |g|
            g.view_specs false
            g.helper_specs false
            g.fixture_replacement :machinist
        end

        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Custom directories with classes and modules you want to be autoloadable.
        # config.autoload_paths += %W(#{config.root}/extras)
        config.autoload_paths += %W(#{config.root}/lib)

        # These monitoring classes can't be reloaded.
        config.autoload_once_paths += %W(#{config.root}/lib/dispatcher_manager.rb)
        config.autoload_once_paths += %W(#{config.root}/lib/scan_manager.rb)

        config.eager_load_paths << Rails.root.join('lib')

        # Only load the plugins named here, in the order given (default is alphabetical).
        # :all can be used as a placeholder for all plugins not explicitly named.
        # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

        # Activate observers that should always be running.
        # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        # config.time_zone = 'Central Time (US & Canada)'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de

        # Configure the default encoding used in templates for Ruby 1.9.
        config.encoding = "utf-8"

        # Enable escaping HTML in JSON.
        config.active_support.escape_html_entities_in_json = true

        # Use SQL instead of Active Record's schema dumper when creating the database.
        # This is necessary if your schema can't be completely dumped by the schema dumper,
        # like if you have constraints or database-specific column types
        # config.active_record.schema_format = :sql

        # Enable the asset pipeline
        config.assets.enabled = true

        # Version of your assets, change this if you want to expire all your assets
        config.assets.version = '1.0'

        if ENV['ARACHNI_WEBUI_LOGDIR']
            config.logger = ActiveSupport::Logger.new( "#{ENV['ARACHNI_WEBUI_LOGDIR']}/#{Rails.env}.log" )
        end
    end
end

require File.expand_path( '../version', __FILE__ )

module ArachniWebui
    class Application
        FULL_VERSION = "#{Arachni::VERSION}-#{ArachniWebui::Application::VERSION}"
    end
end

Arachni::Reactor.global.run_in_thread
Arachni::Reactor.global.on_error do |_, e|
    Rails.logger.error "Arachni::Reactor: #{e}"

    e.backtrace.each do |l|
        Rails.logger.error "Arachni::Reactor: #{l}"
    end
end
