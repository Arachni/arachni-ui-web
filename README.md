**NOTICE**:

* Arachni's license has changed, please see the _LICENSE_ file before working
    with the project.
* v0.5.x is not backwards compatible with v0.4.x.

<hr/>

# Framework v1.1 compatibility branch

This branch contains updates directly related to the under development Framework v1.1.

## Setup

### Linux and OSX

#### Environment setup

Ruby and library dependency installation can take place via either the official
build scripts or manually.

##### Using the build scripts

The build scripts make [setting up a development environment](https://github.com/Arachni/arachni/wiki/Development-environment)
very simple and should generally be preferred.

##### Using RVM

    # Install system dependencies
    sudo apt-get install build-essential curl libcurl3 libcurl4-openssl-dev

    # Install GPG keys to verify RVM files.
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

    # Install RVM and Ruby.
    curl -sSL https://get.rvm.io | bash -s stable --ruby

    # Use Ruby.
    rvm use ruby

You will also need to make sure that [PhantomJs 1.9.2](https://code.google.com/p/phantomjs/downloads/list)
is in your `$PATH`.

#### WebUI installation

    git clone https://github.com/Arachni/arachni-ui-web
    cd arachni-ui-web
    git checkout framework-v1.1

    bundle install

    bundle exec rake db:migrate
    bundle exec rake db:setup

You can now start the WebUI like so:

    bundle exec rails s

You can also run Arachni Framework CLI executables using the the executables under `bin/`.

If you get an error when trying to run Arachni, use `bundle exec` like so:
`bundle exec <executable>`.

### MS Windows

Windows support is experimental and could use some serious testing.
Please give it a go and let us know of any issues that you may come across:

* [Framework](https://github.com/Arachni/arachni/issues)
* [WebUI](https://github.com/Arachni/arachni-ui-web/issues)

#### Environment setup

Due to stability issues with the official Ruby interpreter, Arachni depends on
JRuby to run on MS Windows, utilising the Java Virtual Machine.

* [Install JRuby](https://s3.amazonaws.com/jruby.org/downloads/1.7.18/jruby_windows_x64_jre_1_7_18.exe) -- includes Java.
* Install `libcurl`:
    * [Download curl-7.40.0-win64.zip](http://www.confusedbycode.com/curl/).
    * Place the contents of the `bin` and `dlls` directories under `C:\jruby-1.7.18\bin`.
* Install PhantomJS:
    * [Download](https://phantomjs.googlecode.com/files/phantomjs-1.9.2-windows.zip).
    * Place `phantomjs.exe` under `C:\jruby-1.7.18\bin`.
* [Install Git](https://msysgit.github.io/).

#### WebUI installation

    git clone https://github.com/Arachni/arachni-ui-web
    cd arachni-ui-web
    git checkout framework-v1.1

    rm Gemfile.lock
    jruby -S gem install bundler
    RAILS_ENV=production jruby -S bundle install

    RAILS_ENV=production jruby -S rake db:migrate
    RAILS_ENV=production jruby -S rake db:setup
    RAILS_ENV=production jruby -S rake assets:precompile

You can now start the WebUI like so:

    RAILS_ENV=production jruby -S rackup

You can also run Arachni Framework CLI executables using the the executables under `bin/`:

    jruby bin/arachni -h

#### Known issues

For known Framework issues please see: https://github.com/Arachni/arachni/tree/v1.1#known-issues

# Arachni - Web User Interface

<table>
    <tr>
        <th>Version</th>
        <td>1.0dev</td>
    </tr>
    <tr>
        <th>Homepage</th>
        <td><a href="http://www.arachni-scanner.com">http://arachni-scanner.com</a></td>
    </tr>
    <tr>
        <th>Blog</th>
        <td><a href="http://www.arachni-scanner.com/blog">http://arachni-scanner.com/blog</a></td>
    <tr>
        <th>Github</th>
        <td><a href="https://github.com/Arachni/arachni-ui-web">http://github.com/Arachni/arachni-ui-web</a></td>
     <tr/>
    <tr>
        <th>Documentation</th>
        <td><a href="https://github.com/Arachni/arachni-ui-web/wiki">https://github.com/Arachni/arachni-ui-web/wiki</a></td>
    </tr>
    <tr>
        <th>Support</th>
        <td><a href="http://support.arachni-scanner.com">http://support.arachni-scanner.com</a></td>
    </tr>
    <tr>
       <th>Author</th>
       <td><a href="mailto:tasos.laskos@arachni-scanner.com">Tasos Laskos</a> (<a href="http://twitter.com/Zap0tek">@Zap0tek</a>)</td>
    </tr>
    <tr>
        <th>Twitter</th>
        <td><a href="http://twitter.com/ArachniScanner">@ArachniScanner</a></td>
    </tr>
    <tr>
        <th>Copyright</th>
        <td>2013-2014 Tasos Laskos</td>
    </tr>
    <tr>
        <th>License</th>
        <td>Dual-licensed (Apache License v2.0/Commercial) - (see LICENSE file)</td>
    </tr>
</table>

![Arachni logo](http://arachni.github.com/arachni/logo.png)

## Synopsis

A web user interface and collaboration platform for the
[Arachni](https://github.com/Arachni/arachni) open source web application
security scanner framework.

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
            - Per user limit -- Amount of active scans at any given time per user.
        - Profile
            - Allowed modules.
 - Users can:
    - Manage, create and share Dispatchers with each other.
    - Manage, create, export, import and share Scan configuration Profiles with each other.
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
        - Shared Scans -- Started, paused, resumed, aborted, commented, timed out, suspended.
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
 - Scans can be scheduled to be performed at a later date or at predefined intervals.
    - Recurring scans are incremental, with each occurrence being a separate revision.
 - Scan reports can be exported in multiple formats (HTML, XML, YAML and more).
 - Simple, clean, responsive design suitable for desktops, tablets and mobile phones.

## [Usage](https://github.com/Arachni/arachni-ui-web/wiki)

## Bug reports/Feature requests

Submit bugs using [GitHub Issues](http://github.com/Arachni/arachni-ui-web/issues)
and get support via the [Support Portal](http://support.arachni-scanner.com).

## Contributing

If you make improvements to this application, please share with others.

Before starting any work, please read the [instructions](https://github.com/Arachni/arachni-ui-web/tree/experimental#source)
for working with the source code.

* Fork the project.
* Start a feature branch based on the [experimental](https://github.com/Arachni/arachni-ui-web/tree/experimental)
    branch (`git checkout -b <feature-name> experimental`).
* Add specs for your code.
* Run the spec suite to make sure you didn't break anything (`rake spec`).
* Commit and push your changes.
* Issue a pull request and wait for your code to be reviewed.

## License

Dual-licensed (Apache License v2.0/Commercial) -- please see the _LICENSE_ file
for more information.

## Disclaimer

This is free software and you are allowed to use it as you see fit.
However, neither the development team nor any of our contributors can held
responsible for your actions or for any damage caused by the use of this software.
