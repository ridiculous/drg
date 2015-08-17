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

DRG really wants to help you manage your project's gems. But DRG doesn't want to replace Bundler. Instead we want to build on
it. You can "pin" all your versions to the current version listed in the Gemfile.lock:

```bash
rake drg:pin
```

Which will change gems list in your Gemfile to their full version. So if you have a gemfile that looks like:

```ruby
gem 'rails'
gem 'byebug', require: false
gem 'therubyracer', '~> 0.12', platforms: :ruby

# gotta include ourselves
gem 'drg'
```

to

```ruby
gem 'rails', '4.2.3'
gem 'byebug', '5.0.0', require: false
gem 'therubyracer', '0.12.2', platforms: :ruby

# gotta include ourselves
gem 'drg', '0.3.1'
```

Although, you may want to pin gems with their _minor_ version (which allows updating patches). To do this, just run:

```bash
rake drg:pin:minor
```

This will change a gem listed like

```ruby
gem 'rails', '4.2.3'
```

to 

```ruby
gem 'rails', '~> 4.2'
```

Pinning ignores gems that are fetched from somewhere other than rubygems. For example, gems listed with `:git`, `:github`, 
or `:path` will be ignored.

There is also a `rake drg:pin:major` that does what you think.

This can be combined with `bundle update` to quickly update all gems to the latest patch level.

### Updating Gems

DRG can also try to update all outdated gems to the most recent version. It'll update the gem and run your tests. If your
tests pass, then it'll update your gemfile with the current version. Similar to what Gemnasium offers (experience may vary).

```bash
rake drg:update
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
