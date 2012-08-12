# Arachni WebUI

This is the new Web User Interface for [Arachni](https://github.com/Arachni/arachni).

The interface is under development so depending on when you read this it may just
be a mockup, partially or not at all working.

And now for a general plea:
If you've got any experience with the technologies mentioned in the [Technical details](#technical-details)
section and you'd like to see Arachni become more usable then feel free to get in touch and
I'm sure we'll find something for you to help out with. :)

(This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem provided by the [RailsApps Project](http://railsapps.github.com/).)

## Goals

Not sure if you're aware of this but Arachni's capabilities are immense.

It can be used as a Ruby lib to help you with pretty much any web related task or
as a global Grid of highly sophisticated web application security scanners -- and herein
lies the problem; it's no good having all this power but be unable to tame it.

Enter WebUI, its purpose is to provide a simple, clean, powerful and easy-on-the-eyes
interface to all Arachni's goodies.

The old WebUI had the same goals but it was more of a demo, an exercise of sorts,
an experiment that went a little too far.

This time things are gonna get done right, which is why all involved [technologies](#technical-details)
have been thoroughly researched and chosen because of their proven track-record
as well as their familiarity to both users and developers -- which I hope will
facilitate a certain degree of heightened adoption and community contribution.

And most importantly, implement a blue-sky design in order to uplift cross-domain
synergies via market-wide recognizable interfaces and stuff.

## Technical details

### Ruby on Rails

This application is being developed on:

* Ruby version 1.9.3
* Rails version 3.2.8

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

To setup the WebUI run:

```
git clone git://github.com/Arachni/webui.git
cd webui
bundle install
rake db:setup
rails s puma
```

## Documentation and Support

For the time being, this is the only documentation.

### Issues

Please send your feedback using Github's issue system at
[http://github.com/Arachni/arachni/issues](http://github.com/Arachni/arachni/issues).

## Contributing

If you make improvements to this application, please share with others.

* Fork the project on GitHub.
* Make your feature addition or bug fix.
* Commit with Git.
* Send a pull request.

## Credits

* [Tasos Laskos](https://github.com/Zapotek)

## License

Arachni WebUI is licensed under the Apache License Version 2.0.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.
