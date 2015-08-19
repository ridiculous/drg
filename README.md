# DRG

A Ruby utility to help automate common tasks! Currently includes enhanced dependency management using Bundler. You
can pin Gem versions to the current or the next available level (major, minor, or patch). Can also automatically
update your gems to the latest available version.

## Requirements

* Bundler 1.10+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drg'
```

## Tasks

```bash
rake drg:update
rake drg:pin
rake drg:pin:major
rake drg:pin:minor
rake drg:pin:patch
rake drg:pin:patch_latest
rake drg:pin:minor_latest
rake drg:unpin
```

### drg:update

DRG loves updating gems! Run this command to check for outdated gems and try to update them to the latest available version.
Each outdated gem will be updated, then DRG will run your tests (with `rake`) and if your tests pass, the new version will be written to your Gemfile!

```bash
rake drg:update
```

Easy!

### drg:pin

DRG really wants to help you manage your project's gems. But DRG doesn't want to replace Bundler. Instead, we want to build on
it. Pinning ignores gems that are fetched from somewhere other than rubygems. For example, gems listed with `:git`, `:github`,
or `:path` will be ignored. You can "pin" all your versions to the current version listed in the Gemfile.lock:

```bash
rake drg:pin
```

Will update a Gemfile to their full version:

```ruby
gem 'rails'
gem 'byebug', require: false
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'drg' # need this
```

to

```ruby
gem 'rails', '4.2.3'
gem 'byebug', '5.0.0', require: false
gem 'therubyracer', '0.12.2', platforms: :ruby
gem 'drg', '0.4.1' # need this
```

### drg:pin:minor

Want to pin gems at their _minor_ version?

```bash
rake drg:pin:minor
```

Will update a Gemfile

```ruby
gem 'rails', '4.2.3'
```

to 

```ruby
gem 'rails', '~> 4.2'
```

### drg:pin:patch

Want to pin gems at their _patch_ version?

```bash
rake drg:pin:minor
```

Will update a Gemfile

```ruby
gem 'rails', '4.2.3'
```

to 

```ruby
gem 'rails', '~> 4.2.3'
```

This can be combined with `bundle update` to quickly update all gems to the latest patch or minor level.

### drg:pin:major

Pins your gems at the major level:

 ```bash
 rake drg:pin:major
 ```

### drg:pin:patch_latest

Updates the patch version for each outdated gem to the highest available version. This command should be run after `drg:pin` to ensure your gem versions are normalized.

 ```bash
 rake drg:pin:patch_latest         #=> updates all gems in the Gemfile
 rake drg:pin:patch_latest[<gem>]  #=> updates only the specified <gem>
 ```

### drg:pin:minor_latest

Same as `patch_latest` except it updates the minor version to the latest

 ```bash
 rake drg:pin:minor_latest         #=> updates all gems in the Gemfile
 rake drg:pin:minor_latest[<gem>]  #=> updates only the specified <gem>
 ```

### drg:unpin

Remove the versions from your Gemfile. Start fresh!

```bash
rake drg:unpin
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
