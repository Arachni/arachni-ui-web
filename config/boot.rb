=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@arachni-scanner.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path( '../../Gemfile', __FILE__ )

require 'bundler/setup' if File.exists?( ENV['BUNDLE_GEMFILE'] )
