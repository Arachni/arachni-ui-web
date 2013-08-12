# ChangeLog

## 0.4.2 _(August 10, 2013)_

- Fixed bug causing the system to hang after `1:24` hours of scan monitoring,
    caused by improper caching of RPC clients.
- Scan
    - Monitoring
        - Redirect to the Scans list page with an alert if the monitored scan
            was deleted.
- Profiles
    - Added HTTP auth options.

## Version 0.4.1.1 _(July 14, 2013)_

- Login-screen
    - Disabled AJAX refreshing of top-level menu.
- Scan
    - Monitoring
        - Fixed bug causing the error log not to appear when there are errors.

## Version 0.4.1 _(July 06, 2013)_

- Added welcome screen after first sign-in.
- Added support for PostgreSQL along with sample database configuration file (`config/database.yml.pgsql`).
- Added `script/import` to import database and their configurations from older
    packages.
- Switched to <a href="http://github.github.com/github-flavored-markdown/">GitHub-flavored Markdown</a>.
- Profiles
    - Added configuration options for the new platform fingerprinting feature.
- Login page
    - Added a notice for first-time users about the location of the default credentials.
- Scans
    - Index
        - Added resume/pause/abort all buttons.
    - Monitoring
        - Fixed "Share" button to show the modal dialog with the share form.
    - New scan
        - Removed multi-Instance scan warnings and updated Grid behavior as per
            the framework changes.

## Version 0.4 _(April 28, 2013)_

- First version.
