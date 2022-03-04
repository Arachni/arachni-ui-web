=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module ScanGroupsHelper
    def prepare_scan_group_tab_data
        @scan_group  = ScanGroup.new
        @scan_groups = Hash.new([])

        @scan_groups['yours']  = current_user.own_scan_groups
        @scan_groups['shared'] = current_user.shared_scan_groups

        if current_user.admin?
            @scan_groups['others'] = current_user.others_scan_groups
        end
    end
end
