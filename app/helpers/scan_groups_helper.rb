=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
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
