# DRG

A Ruby utility to help automate common tasks! Currently includes stuff like enhanced dependency management using Bundler and RSpec scaffolding.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drg'
```

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

it'll get changed to

```ruby
gem 'rails', '4.2.3'
gem 'byebug', '5.0.0', require: false
gem 'therubyracer', '0.12.2', platforms: :ruby

# gotta include ourselves
gem 'drg', '0.4.1'
```

Although, you may want to pin gems with their _minor_ version (which allows updating patches). Run:

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

There is also a `rake drg:pin:major` which does what you think.

This can be combined with `bundle update` to quickly update all gems to the latest patch or minor level.

### Updating Gems

DRG can also try to update all outdated gems to the most recent version. It'll update the gem and run your tests. If your
tests pass, then it'll update your gemfile with the current version. Similar to what Gemnasium offers (experience may vary).

```bash
rake drg:update
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
