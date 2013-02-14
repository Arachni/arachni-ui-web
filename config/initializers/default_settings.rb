require 'ostruct'

::Settings = OpenStruct.new

Settings.dashboard_refresh_rate           = 5000
Settings.scan_refresh_rate                = 5000
Settings.comments_refresh_rate            = 5000
Settings.dispatcher_refresh_rate          = 5000

Settings.active_scan_pagination_entries   = 20
Settings.finished_scan_pagination_entries = 15

Settings.activities_pagination_entries    = 20
Settings.notifications_pagination_entries = 20
Settings.profile_pagination_entries       = 20
