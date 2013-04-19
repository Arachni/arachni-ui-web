# Arachni WebUI

This is the new Web User Interface for [Arachni](https://github.com/Arachni/arachni).

The interface is under development so there can be bugs that haven't been fixed
yet or stability issues.

For self-contained, nightly snapshot packages take a look at:
http://downloads.arachni-scanner.com/nightlies/

(This application was generated with the
[rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.com/).)

## Features

 - Administrators can manage all:
    - Users
    - Scan configuration Profiles
        - Can set Global Profiles which are available to everyone.
        - Can set the system-wide default Profile.
    - Scans
    - Scan Issues
    - Scan Groups
    - Dispatchers
        - Can set Global Dispatchers which are available to everyone.
        - Can set the system-wide default Dispatcher.
    - Settings
        - Scan
            - Allowed types.
            - Target whitelist using regular expressions.
            - Target blacklist using regular expressions.
            - Global scan limit -- Amount of active scans at any given time.
            - Per scan limit -- Amount of active scans at any given time per user.
        - Profile
            - Allowed modules.
 - Users can:
    - Manage, create and share Dispatchers with each other.
    - Manage, create and share Scan configuration Profiles with each other.
    - Start Scans using one of the available Profiles (and optionally Dispatchers).
    - Organize Scans into Scan Groups for easier management and share their Groups with each other.
    - Manage, comment, share and export reports of their Scans.
    - Discuss and Review Issues:
        - Mark them as false positives
        - Mark them as fixed
        - Mark them as requiring manual verification
            - Add verification steps
            - Mark them as verified
    - Receive Notifications for:
        - Shared Profiles -- Created, updated, shared, deleted.
        - Shared Scans -- Started, paused, resumed, aborted, commented.
        - Issues of shared Scans -- Reviewed, verified, commented.
    - Review their Activity.
    - Export reports, review and comment on Scans which have been shared with them by other users.
 - Available Scan types:
    - Direct -- From the WebUI machine to the webapp, no need to setup anything else.
    - Remote -- Using a Dispatcher.
        - Scan is performed from the machine of the Dispatcher to the webapp.
        - Scan assignments can be load balanced when there are multiple Dispatchers available.
    - Grid -- Using multiple Dispatchers.
        - Scan is performed using multiple machines for a super-fast crawl and audit.
        - Scan assignments can be load balanced.
    - Repeat/Revision
        - Repeats a finished scan to identify fixed or new issues.
        - Can use sitemaps of previous revisions to:
            - Avoid crawling
            - Extend a new crawl
    - Overview -- Combines the results of multiple revisions for easy review/management.
 - Scan reports can be exported in multiple formats (HTML, XML, YAML and more).
 - Simple, clean, responsive design suitable for desktops, tablets and mobile phones.

## Technical details

### Ruby on Rails

This application is being developed on:

* Ruby version 1.9.3
* Rails version 4.0

### Database

This application uses SQLite with ActiveRecord.

### Development

* Template Engine: ERB
* Testing Framework: RSpec and Machinist and Cucumber
* Front-end Framework: Twitter Bootstrap (Sass)
* Form Builder: SimpleForm
* Authentication: Devise
* Authorization: CanCan

## Getting Started

The WebUI is still under development so there are no packages for it yet.
To get it running you'll have to run the following (assuming a Debian-based OS):

```
# Arachni Framework dependencies, along with some Rails ones.
sudo apt-get install build-essential libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev libyaml-dev zlib1g-dev ruby1.9.1-dev ruby1.9.1 git libv8-dev

sudo gem install bundler

git clone https://github.com/Arachni/arachni-ui-web
cd arachni-ui-web

# --binstubs will make the executables of the Framework available under 'bin/',
# so that you'll be able to run the CLI if needed.
bundle install --binstubs

rake db:migrate
rake db:setup
script/rails s thin
```

For seed data (default user accounts etc) take a look in ```db/seeds.rb```.

Also, the DB schema is pretty fluid during development so migrate after each
```git pull``` and don't be surprised if you'll have to remove the existing schema
and DBs for things to work again:

```
rm db/development.sqlite3
rm db/test.sqlite3
rm db/schema.rb
rake db:migrate
rake db:setup
```

## Documentation and Support

For the time being, this is the only documentation.

### Issues

Please send your feedback using Github's issue system at
[http://github.com/Arachni/arachni-ui-web/issues](http://github.com/Arachni/arachni-ui-web/issues).

## Contributing

If you make improvements to this application, please share with others.

* [Fork the project](https://github.com/Arachni/arachni-ui-web/fork_select).
* Start a feature branch based on the `experimental` branch (```git checkout -b <feature-name> experimental```).
* Add specs for your code.
* Run the spec suite to make sure you didn't break anything (```rake spec:core```
    for the core libs or ```rake spec``` for everything).
* Commit and push your changes.
* Issue a pull request and wait for your code to be reviewed.

## Credits

* [Tasos Laskos](mailto:tasos.laskos@gmail.com)

## License

Arachni WebUI is licensed under the Apache License Version 2.0.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.
