require 'ostruct'

::HardSettings = OpenStruct.new

HardSettings.dashboard_refresh_rate           = 5000
HardSettings.scan_refresh_rate                = 5000
HardSettings.comments_refresh_rate            = 5000
HardSettings.dispatcher_refresh_rate          = 5000

HardSettings.active_scan_pagination_entries   = 20
HardSettings.finished_scan_pagination_entries = 15
HardSettings.scheduled_scan_pagination_entries= 50

HardSettings.activities_pagination_entries    = 20
HardSettings.notifications_pagination_entries = 20
HardSettings.profile_pagination_entries       = 20
HardSettings.dispatcher_pagination_entries    = 20

HardSettings.max_running_scans_per_user = 5
HardSettings.max_running_scans          = 20
