# ChangeLog

## 0.6.1.1 (May 3, 2022)

- Added alert informing of obsolescence and [SCNR](https://ecsypno.com/scnr-documentation/).

## 0.6.1 (March 20, 2022)

- Fixed redirect back calls.

## 0.6.0 (March 4, 2022)

- Updated to Rails 6.
- Profile
    - Fixed bug causing plugins values to be overwritten on edit.
    - Added audit nested cookies option.
    - Fixed default value of "scope exclude file extentions" option.

## 0.5.12 (March 29, 2017)

- Hide affixed sidebar on smaller screens to prevent overlaps.
- Notifications:
    - Updated to sanitize scan targets.

## 0.5.11 (January 21, 2017)

- Profile
    - Scope: Validate regular expressions.
    - Added "exclude file extensions" option.
    - Added "HTTP authentication type" option.
- Issue
    - Fixed incompatible encoding error when displaying vector inputs.

## 0.5.10 _(February 8, 2016)_

- Switched to absolute paths instead of full URLs across the interface.
- User
    - `#name` -- Force encoding to UTF8.
- Profile
    - `#name` -- Force encoding to UTF8.
    - Whitelisted `scope_exclude_binaries` option.
    - Form
        - Show HTTP proxy types as drop-down.

## 0.5.9 _(October 20, 2015)_

- Scan
    - Progress page
        - Fixed bug causing scroll offset not to be maintained between AJAX
            refreshes on Chrome.

## 0.5.8 _(October 17, 2015)_

- Profiles
    - Added UI form and UI input audit options.
- Changed `text` DB columns that may contain `null`-bytes to `binary`.
    - **Breaks backwards compatibility.**

## 0.5.7.1 _(July 16, 2015)_

- Switched to Arachni Public Source License v1.0.
- Updated Rails dependency.
- Re-enabled update script.

## 0.5.7 _(May 1, 2015)_

- `Scan`
    - Improved error logging.
    - Removed charts from progress page due to JS memory leak.
- `Report`
    - `#object` serialization now uses `MessagePack` to fix encoding errors and
        improve performance. (**Breaks backwards compatibility**)
- `Profile`
    - `#strong_params` -- Fixed parameter whitelist, causing some options to
        be ignored.
    - Added audit options for JSON and XML inputs.

## 0.5.6 _(November 14, 2014)_

- `Profile`
    - `#export` -- Fixed error on YAML/JSON exporting.
    - Fixed plugin option validation.
    - Fixed bug causing stored plugin options not to be shown in their forms.
- `Scan`
    - Only stop the scan when an RPC connection error occurs, not for every
        RPC exception.

## 0.5.5 _(October 25, 2014)_

- Scans
    - Show error message when the full report could not be retrieved instead
        of crashing.

## 0.5.4 _(October 7, 2014)_

- Profile
    - Added the `http_response_max_size` option.
- `ProfilesController`
    - Added `http_request_queue_size` option to the permitted parameters.

## 0.5.3 _(September 13, 2014)_

- Scan
    - Added support for exporting reports as AFR (Arachni Framework Report).

## 0.5.2 _(September 7, 2014)_

- `Dispatcher`
    - Remove RPC clients of deleted or unreachable Dispatchers from the cache.
    - `#preferred` -- Only include reachable Dispatchers.
- `Scan`
    - `#start` -- Only set status to `active` after the RPC call, to avoid a race
        condition.
    - Improved logging of RPC errors.
    - Fixed loose-typing bug when using PostgreSQL.
- `Issue`
    - Fixed loose-typing bug when using PostgreSQL.
- `Profile`
    - `#to_rpc_options`
        - Sanitize hash via `Arachni::Options.hash_to_rpc_data`.
        - Only use the configured input values and ignore Framework defaults.

## 0.5.1 _(September 01, 2014)_

- `Gemfile`: Include `pg` gem.

## 0.5 _(August 29, 2014)_

- Admin can no longer delete self.
- Fixed XSS on Markdown inputs [Issue #71].
- Issue
    - Data to include DOM information.
    - Description and remedy guidance textx are now rendered as GitHub-flavored Markdown.
- Profiles
    - Updated options for Framework v1.0.
    - Check and plugin information now rendered as GitHub-flavored Markdown.
- Scans
    - Added suspension support.
    - Added import support via AFR report files.
    - Added support for scheduled scan termination.
        - With optional suspension.
    - Report filenames now include scan URL, profile name and scan ID.
- Added `scan_import` script, allowing AFR reports to be imported as scans via
    a CLI.

## 0.4.4 _(April 12, 2014)_

- External links now open in new windows.

## 0.4.3 _(January 1, 2014)_

- Removed Turbolinks as it breaks Bootstrap modals.
- Updated to use HTML5 `localStorage` instead of cookies to store UI state.
- Navigation menu
    - Removed "Home" item since it was redundant.
    - Updated JS detection of active page when the WebUI is mounted under a subdirectory.
- Profiles
    - Added Regexp validation for the login-check-pattern input.
    - Added Import and Export/Download functionality, supporting:
        - YAML -- Including the CLI AFP files.
        - JSON
    - Delete dialog now warns of the existence of associated Scans.
    - Added support for the `http_queue_size` option.
    - Fixed formatting of cookies as an `RPC::Server::Instance#scan` option.
    - Component selection accordions are now zebra-styled [Issue #57].
- Scans
    - Index
        - Fixed a nil error caused when a Scan's Profile has been deleted.
    - Can now be edited.
    - Can be scheduled, with support for recurring (incremental/differential) Scans.
    - Issues
        - Fixed encoding error when handling request parameters [Issue #39].
        - Redesigned table to group issues by type [Issue #52].
        - Updated severity colors.
    - Reporting
        - Removed Metareport and Text reports as they were unusable via the WebUI.
        - Added proper content-types for all reports.
- Settings
    - Profiles
        - Fixed heading (_Profiles_ => _Plugins_).
    - Added "General" tab.
        - Added Timezone setting.

## 0.4.2.1 _(September 18, 2013)_

- Scan monitoring
    - Keep track of (and restore) the window scroll position between AJAX refreshes.

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
