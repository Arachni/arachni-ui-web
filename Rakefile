#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path( '../config/application', __FILE__ )

ArachniWebui::Application.load_tasks

namespace :version do
    task :interface do
        puts ArachniWebui::Application::VERSION
    end

    task :framework do
        puts Arachni::VERSION
    end

    task :full do
        puts ArachniWebui::Application::FULL_VERSION
    end
end
