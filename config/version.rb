=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@arachni-scanner.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module ArachniWebui
    class Application
        VERSION = IO.read( File.expand_path( '../VERSION', File.dirname( __FILE__ ) ) ).strip
    end
end
