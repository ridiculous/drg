# DRG

A Ruby utility to help automate common tasks! Currently includes stuff like enhanced dependency management using Bundler and RSpec scaffolding.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install drg

## Usage

### Pinning Gems

DRG can help you manage your project's gems by updating your Gemfile with pinned versions. Just run:

```bash
rake drg:pin
```

Will also try to update all your gems to the most recent version (coming soon).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
