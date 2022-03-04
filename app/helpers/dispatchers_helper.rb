=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module DispatchersHelper

    def dispatcher_filter( filter )
        filter ||= 'yours'

        case filter
            when 'yours'
                current_user.own_dispatchers
            when 'shared'
                current_user.shared_dispatchers
            when 'global'
                Dispatcher.global

            when 'others'
                raise 'Unauthorised!' if !current_user.admin?
                current_user.others_dispatchers
        end
    end

end
