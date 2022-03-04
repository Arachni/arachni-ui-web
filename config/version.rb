=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module ArachniWebui
    class Application
        VERSION = IO.read( File.expand_path( '../VERSION', File.dirname( __FILE__ ) ) ).strip
    end
end
