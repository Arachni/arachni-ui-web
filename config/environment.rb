=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Load the rails application
require File.expand_path( '../application', __FILE__ )

# Initialize the rails application
ArachniWebui::Application.initialize!

if Rails.env != 'test'
    ScanManager.monitor
    DispatcherManager.monitor
end
