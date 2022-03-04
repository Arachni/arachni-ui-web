=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module NotificationsHelper

    def notify( model, opts = {} )
        opts = (opts || {}).dup

        opts[:actor]  ||= current_user
        opts[:action] ||= params[:action]

        model.notify( opts )
    end

end
